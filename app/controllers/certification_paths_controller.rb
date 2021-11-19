class CertificationPathsController < AuthenticatedController
  include ActionView::Helpers::TranslationHelper
  include ApplicationHelper
  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project

  before_action :set_controller_model, except: [:create, :list]
  # TODO ???????????
  # before_action :certificate_exists_and_is_allowed, only: [:apply, :new, :create]

  def show
    respond_to do |format|
      format.html {
        @page_title = ERB::Util.html_escape(@project.name.to_s)
        @tasks = TaskService::get_tasks(page: params[:page], per_page: 25, user: current_user, project_id: @project.id, certification_path_id: @certification_path.id)
      }
      format.json { render json: {id: @certification_path.id, name: @certification_path.name}, status: :ok }
    end
  end

  def apply
    # Prevent adding multiple certification paths of the same type
    if @project.certificates.pluck(:certification_type).include?(params[:certification_type].to_i)
      respond_to do |format|
        format.js {
          flash.now[:alert] = t('controllers.certification_paths_controller.apply.already_applied')
          return render 'apply'
        }
        format.html {
          return redirect_to(project_path(@project), alert: t('controllers.certification_paths_controller.apply.already_applied'))
        }
      end
    end

    # create a new object, for our project
    @certification_path = CertificationPath.new(project_id: @project.id)
    # check if the user is authorized to apply for a new certification_path in our project
    authorize! :apply, @certification_path

    # To determine the certificate, we need both the certification_type and the gsas_version
    #  - The certification_type is passed as part of the url
    #  TODO: verify 'certification_type', as it is a required param !
    @certification_type = Certificate.certification_types.key(params[:certification_type].to_i)

    # Note: FinalDesign reuses the version from LetterOfConformance !!
    if Certificate.certification_types[@certification_type] == Certificate.certification_types[:final_design_certificate]
      @gsas_version = @certification_path.project.completed_letter_of_conformances.first.certificate.gsas_version
    elsif (Certificate.certification_types[@certification_type] == Certificate.certification_types[:construction_certificate_stage2]) || (Certificate.certification_types[@certification_type] == Certificate.certification_types[:construction_certificate_stage3])
      @gsas_version = @certification_path.project.completed_construction_stage1.first.certificate.gsas_version
    else
      #  - The gsas_version can be passed as post data, but we also provide a default based on the available data
      #  TODO: verify 'gsas_version' is valid
      # TODO remove next line when D&B2019 and CM2019 can be made available for production
      # unless Rails.env.production? && (Certificate.certification_types[@certification_type] == Certificate.certification_types[:letter_of_conformance] || Certificate.certification_types[@certification_type] == Certificate.certification_types[:construction_certificate_stage1])
        @gsas_versions = Certificate.with_certification_type(Certificate.certification_types[@certification_type]).order(gsas_version: :desc).distinct.pluck(:gsas_version, :gsas_version)
      # else
      #   @gsas_versions = Certificate.with_certification_type(Certificate.certification_types[@certification_type]).where.not(gsas_version: '2019').order(gsas_version: :desc).distinct.pluck(:gsas_version, :gsas_version)
      # end
      if params.has_key?(:gsas_version)
        @gsas_version = params[:gsas_version]
      else
        @gsas_version = @gsas_versions.first
      end
    end
        
    if Certificate.certification_types[@certification_type] == Certificate.certification_types[:final_design_certificate]
      @certificate_method = @certification_path.project.completed_letter_of_conformances.first.certification_path_method
      @assessment_method = if !@certificate_method.present?
                              1
                           else
                              @certificate_method.assessment_method
                           end
    else
      if params.has_key?(:assessment_method)
        @assessment_method = params[:assessment_method].to_i
      else
        @assessment_method = 1
      end
    end

    #  - Determine the resulting certificate, and add it to our certification_path
    #  TODO: verify there is only 1 certificate
    @certificates = Certificate.with_gsas_version(@gsas_version).with_certification_type(Certificate.certification_types[@certification_type])
    @certification_path.certificate = @certificates.first

    # Force NO PCR for construction certificates
    if params.has_key?(:certification_path) && params[:certification_path].has_key?(:pcr_track) && @certification_path.certificate.construction_type?
      params[:pcr_track] = false
    end

    # PCR Track
    if params.has_key?(:certification_path) && params[:certification_path].has_key?(:pcr_track)
      @certification_path.pcr_track = params[:certification_path][:pcr_track]
    else
      @certification_path.pcr_track = false
    end

    # Expiry
    if @certification_path.certificate.letter_of_conformance?
      @certification_path.expires_at = 1.year.from_now
    elsif @certification_path.certificate.final_design_certificate?
      @durations = [2, 3, 4]
      if params.has_key?(:certification_path) && params[:certification_path].has_key?(:expires_at)
        @certification_path.expires_at = params[:certification_path][:expires_at].to_i.years.from_now
      else
        @certification_path.expires_at = @durations.first.years.from_now
      end
    end

    # Development Type
    # Note: FinalDesign uses a similar DevelopmentType as Letter Of Conformace !!
    if Certificate.certification_types[@certification_type] == Certificate.certification_types[:final_design_certificate]
      # Note: we currently use the name to match, this could be done cleaner
      development_type_name = @certification_path.project.completed_letter_of_conformances.first.development_type.name
      @certification_path.development_type = DevelopmentType.find_by(name: development_type_name, certificate: @certification_path.certificate)
    else
      @development_types = @certification_path.certificate.development_types
      if params.has_key?(:certification_path) && params[:certification_path].has_key?(:development_type)
        @certification_path.development_type = DevelopmentType.find_by_id(params[:certification_path][:development_type].to_i)
      else
        @certification_path.development_type = @certification_path.certificate.development_types.first
      end
    end

    if Certificate.certification_types[@certification_type] == Certificate.certification_types[:final_design_certificate]
      # Mirror the LOC scheme mixes
      @certification_path.project.completed_letter_of_conformances.first.scheme_mixes.each do |scheme_mix|
        # if a scheme certification type is available
        unless scheme_mix.scheme.certification_type.nil?
          loc_scheme = scheme_mix.scheme
          scheme_id = Scheme.select(:id).find_by(name: loc_scheme.name, gsas_version: loc_scheme.gsas_version, certificate_type: loc_scheme.certificate_type, certification_type: Certificate.certification_types[:final_design_certificate])
          scheme_id = scheme_id.id
        else
          scheme_id = scheme_mix.scheme_id
        end

        new_scheme_mix = @certification_path.scheme_mixes.build({scheme_id: scheme_id, weight: scheme_mix.weight, custom_name: scheme_mix.custom_name})
        # Mirror the main scheme mix
        if @certification_path.project.completed_letter_of_conformances.first.main_scheme_mix_id.present? && (scheme_mix.id == @certification_path.project.completed_letter_of_conformances.first.main_scheme_mix_id)
          @certification_path.main_scheme_mix = new_scheme_mix
          @certification_path.main_scheme_mix_selected = true
        end
      end
    else
      if @certification_path.development_type.mixable?
        if params[:certification_path].has_key?(:schemes)
          params[:certification_path][:schemes].each do |scheme_params|
            if scheme_params[:custom_name].blank?
              scheme_params[:custom_name] = nil
            end
            @certification_path.scheme_mixes.build({scheme_id: scheme_params[:scheme_id], weight: scheme_params[:weight], custom_name: scheme_params[:custom_name]})
          end
        end
      else
        if params.has_key?(:single_scheme_select)
          @certification_path.scheme_mixes.build({scheme_id: params[:single_scheme_select], weight: 100})
        end
      end
    end

    respond_to do |format|
      # refresh modal using js, to show updated values, based on the received post data
      format.js {
        return render 'apply'
      }
      # save the certificate, as the user has clicked save
      format.html {
        if @certification_path.save
          @certification_path.create_assessment_method(@assessment_method) if @project.design_and_build?
          @project.update!(service_provider_2: current_user&.employer_name) if @certification_path&.certificate&.certification_type == "final_design_certificate"
          @project.project_rendering_images.where(certification_path_id: nil).update(certification_path_id: @certification_path.id)
          @project.actual_project_images.where(certification_path_id: nil).update(certification_path_id: @certification_path.id)
          return redirect_to(project_certification_path_path(@project, @certification_path), notice: t('controllers.certification_paths_controller.apply.success'))
        else
          return redirect_to(project_path(@project), alert: t('controllers.certification_paths_controller.apply.error'))
        end
      }
    end
  end

  def apply_for_pcr
    if @certification_path.update!(:pcr_track => true)
      redirect_to project_certification_path_path(@project, @certification_path), notice: 'Successfully applied for PCR track'
    end
  end

  def cancel_pcr
    if @certification_path.update!(:pcr_track => false)
      redirect_to project_certification_path_path(@project, @certification_path), notice: 'PCR is cancelled'
    end
  end

  def edit_status
  end

  def update_status
    CertificationPath.transaction do
      todos = @certification_path.todo_before_status_advance

      if todos.blank?
        # Check if there's an appeal
        # For construction management 2019 appeal can only be requested during stage 3
        unless certification_path_params.has_key?(:appealed) && @certification_path.certificate.construction_2019? && !@certification_path.certificate.construction_certificate_stage3?
          @certification_path.appealed = certification_path_params.has_key?(:appealed)
        end

        # Retrieve & save the next status
        @certification_path.certification_path_status_id = @certification_path.next_status
        @certification_path.audit_log_user_comment = params[:certification_path][:audit_log_user_comment]
        @certification_path.audit_log_visibility =  params[:certification_path][:audit_log_visibility]
        @certification_path.save!
        # sent email if the certificate is approved
        if @certification_path.status == "Certified"
           DigestMailer.certificate_approved_email(@certification_path).deliver_now
        end
        # If there was an appeal, set the status of the selected criteria to 'Appealed'
        if certification_path_params.has_key?(:appealed) && params.has_key?(:scheme_mix_criterion)
          params[:scheme_mix_criterion].each do |smc_id|
            SchemeMixCriterion.find(smc_id.to_i).appealed!
          end
        end

        # Create Construction Certificate if Construction certificate stage 3 is certified
        if @certification_path.is_completed? && @certification_path.certificate.construction_certificate_stage3?
          average_scores = @project.average_scores_all_construction_stages

          certificate = Certificate.find_by(certification_type: Certificate.certification_types[:construction_certificate], display_weight: 39, gsas_version: @certification_path.certificate.gsas_version)
          # Only 1 pseudo development type linked to this certificate
          development_type = certificate.development_types.first
          # Only set certificate path to approving_by_top_management if all construction stages are certified
          if @project.are_all_construction_stages_certified?
            status = CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT
          else
            status = CertificationPathStatus::NOT_CERTIFIED
          end
          overall_certification_path = CertificationPath.new(project: @project, certificate: certificate, certification_path_status_id: status, main_scheme_mix_selected: false, development_type: development_type, started_at: Time.zone.now, certified_at: Time.zone.now)
          # Only 1 pseudo scheme linked to this development type
          scheme = development_type.schemes.first
          overall_certification_path.scheme_mixes.build(scheme: scheme, weight: 100)
          overall_certification_path.save!
          scheme.scheme_criteria.each do |scheme_criterion|
            SchemeMixCriterion.create!(scheme_mix: overall_certification_path.scheme_mixes.first, scheme_criterion: scheme_criterion, targeted_score_a: average_scores[:targeted_score], submitted_score_a: average_scores[:submitted_score], achieved_score_a: average_scores[:achieved_score])
          end
        end

        redirect_to project_certification_path_path(@project, @certification_path), notice: t('controllers.certification_paths_controller.update_status.notice_success')
      else
        redirect_to project_certification_path_path(@project, @certification_path), alert: todos.first
      end
    end
  end

  def download_archive
    last_archive = Archive.order(created_at: :desc).find_by(user_id: current_user.id, subject: @certification_path)

    if last_archive.present? && (last_archive.created_at > (Time.now - 3.minutes))
      redirect_to project_certification_path_path(@project, @certification_path), alert: 'You have recently requested an archive for this certificate.'
    else
      archive = Archive.new
      archive.user_id = current_user.id
      archive.subject = @certification_path
      archive.status = :not_generated
      archive.save!
      redirect_to project_certification_path_path(@project, @certification_path), notice: 'A ZIP archive is being generated. You will be notified by email when the file can be downloaded.'
    end
  end

  def list
    total_count = CertificationPath.joins(:certificate)
                      .where(project_id: @project.id)
                      .where('certificates.name like ?', '%' + params[:q] + '%')
                      .count
    items = CertificationPath.select('certification_paths.id as id, certificates.name as text, certification_paths.certification_path_status_id')
                .joins(:certificate)
                .where(project_id: @project.id)
                .where('certificates.name like ?', '%' + params[:q] + '%')
                .page(params[:page]).per(25)
    render json: {total_count: total_count, items: items}
  end

  def edit_project_team_responsibility_for_submittal
    @page_title = t('controllers.certification_paths_controller.edit_project_team_responsibility_for_submittal.page_title', certificate: @certification_path.name)
  end

  def edit_certifier_team_responsibility_for_verification
    @page_title = t('controllers.certification_paths_controller.edit_certifier_team_responsibility_for_verification.page_title', certificate: @certification_path.name)
  end

  def edit_certifier_team_responsibility_for_screening
    @page_title = t('controllers.certification_paths_controller.edit_certifier_team_responsibility_for_screening.page_title', certificate: @certification_path.name)
  end

  def allocate_project_team_responsibility_for_submittal
    if params.has_key?(:requirement_data)
      # Format the user id
      if params[:user_id].empty?
        user = nil
      else
        user = User.find(params[:user_id])
      end

      # Format the due date
      if params[:due_date].empty?
        due_date = nil
      else
        due_date = Date.strptime(params[:due_date], t('date.formats.short'))
      end

      # Format the status
      if params[:status].empty?
        status = nil
      else
        status = params[:status]
      end

      # Load the RequirementDatum models
      requirement_data = RequirementDatum.find(params[:requirement_data])

      # Update the RequirementDatum models
      all_saved = true
      CertificationPath.transaction do
        requirement_data.each do |requirement_datum|
          if can?(:update, requirement_datum)
            requirement_datum.update!(user: user, due_date: due_date, status: status)
          else
            all_saved = false
          end
        end
      end

      if all_saved
        flash[:notice] = 'The selected requirements were successfully updated.'
      else
        flash[:alert] = 'Not all requirements were successfully updated because some criteria are already submitted.'
      end
    else
      flash[:alert] = 'No requirements were selected.'
    end

    if params.has_key?(:button) && (params[:button] == 'save-and-continue')
      redirect_to edit_project_team_responsibility_for_submittal_project_certification_path_path
    else
      redirect_to project_certification_path_path
    end
  end

  def allocate_certifier_team_responsibility_for_verification
    if params.has_key?(:scheme_mix_criteria)
      # Format the certifier id
      if params[:certifier_id].empty?
        certifier = nil
      else
        certifier = User.find(params[:certifier_id])
      end

      # Format the due date
      if params[:due_date].empty?
        due_date = nil
      else
        due_date = Date.strptime(params[:due_date], t('date.formats.short'))
      end

      # Load the SchemeMixCriteria models
      scheme_mix_criteria = SchemeMixCriterion.find(params[:scheme_mix_criteria])

      # Update the SchemeMixCriteria models
      all_saved = true
      CertificationPath.transaction do
        scheme_mix_criteria.each do |scheme_mix_criterion|
          if can?(:assign_certifier, scheme_mix_criterion)
            scheme_mix_criterion.update!(certifier: certifier, due_date: due_date)
          else
            all_saved = false
          end
        end
      end

      if all_saved
        flash[:notice] = 'The selected criteria were successfully updated.'
      else
        flash[:alert] = 'Not all criteria were successfully updated because they are already verified.'
      end
    else
      flash[:alert] = 'No criteria were selected.'
    end

    if params.has_key?(:button) && (params[:button] == 'save-and-continue')
      redirect_to edit_certifier_team_responsibility_for_verification_project_certification_path_path
    else
      redirect_to project_certification_path_path
    end
  end

  def allocate_certifier_team_responsibility_for_screening
    if params.has_key?(:scheme_mix_criteria)
      # Format the certifier id
      if params[:certifier_id].empty?
        certifier = nil
      else
        certifier = User.find(params[:certifier_id])
      end

      # Format the due date
      if params[:due_date].empty?
        due_date = nil
      else
        due_date = Date.strptime(params[:due_date], t('date.formats.short'))
      end

      # Format the screened flag
      screened = params.has_key?(:mark_as_screened)

      # Load the SchemeMixCriteria models
      scheme_mix_criteria = SchemeMixCriterion.find(params[:scheme_mix_criteria])

      # Update the SchemeMixCriteria models
      all_saved = true
      CertificationPath.transaction do
        scheme_mix_criteria.each do |scheme_mix_criterion|
          if can?(:assign_certifier, scheme_mix_criterion)
            scheme_mix_criterion.update!(certifier: certifier, due_date: due_date, screened: screened)
          else
            all_saved = false
          end
        end
      end

      if all_saved
        flash[:notice] = 'The selected criteria were successfully updated.'
      else
        flash[:alert] = 'Not all criteria were successfully updated because they are already screened.'
      end
    else
      flash[:alert] = 'No criteria were selected.'
    end

    if params.has_key?(:button) && (params[:button] == 'save-and-continue')
      redirect_to edit_certifier_team_responsibility_for_screening_project_certification_path_path
    else
      redirect_to project_certification_path_path
    end
  end

  def edit_main_scheme_mix
  end

  def update_main_scheme_mix
    if params[:certification_path].has_key?(:main_scheme_mix_id) && @certification_path.update!(main_scheme_mix_id: params[:certification_path][:main_scheme_mix_id], main_scheme_mix_selected: true)
      redirect_to project_certification_path_path(@project, @certification_path), notice: 'The main scheme was successfully saved.'
    else
      redirect_to project_certification_path_path(@project, @certification_path), alert: 'An error occurred when saving the main scheme. Please try again later.'
    end
  end

  def edit_max_review_count

  end

  def update_max_review_count
    @certification_path.max_review_count = params[:certification_path][:max_review_count]
    @certification_path.save!
    flash[:notice] = 'The maximum number of PCR is saved succesfully.'
    redirect_to project_certification_path_path
  end

  def edit_expires_at

  end

  def update_expires_at
    @certification_path.expires_at = params[:certification_path][:expires_at]
    @certification_path.save!
    flash[:notice] = 'The expiry date is saved successfully.'
    redirect_to project_certification_path_path
  end

  # PDF REPORT GENERATION IS DISABLED!
  # To re-enable it:
  #   - uncomment the routes in /config/routes.rb
  #   - uncomment the download buttons in /app/views/certification_paths/show.html.erb
  #   - uncomment the functions in certification_paths_controller
  # def download_certificate_report
  #   filepath = filepath_for_report 'Certificate'
  #   # if not File.exists?(filepath)
  #   report = Reports::CertificateReport.new(@certification_path)
  #   report.save_as(filepath)
  #   # end
  #   send_file filepath, :type => 'application/pdf', :x_sendfile => true
  # end

  def download_coverletter_report
    filepath = filepath_for_report 'Cover Letter'
    report = Reports::LetterOfConformanceCoverLetter.new(@certification_path)
    report.save_as(filepath)
    send_file filepath, :type => 'application/pdf', :x_sendfile => false
  end

  def confirm_destroy
  end

  def destroy
    if @certification_path.destroy
      redirect_to project_path(@project), notice: 'The certification was successfully removed.'
    else
      redirect_to project_path(@project), alert: 'An error occurred when trying to remove the certification. Please try again later.'
    end
  end

  def confirm_deny
  end

  def deny
    @certification_path.certification_path_status_id = CertificationPathStatus::NOT_CERTIFIED
    @certification_path.save!
    redirect_to project_path(@project), notice: 'The certification was successfully denied.'
  end

  def update_signed_certificate
    if params[:certification_path].present? && params[:certification_path][:signed_certificate_file].present?
      @certification_path.signed_certificate_file = params[:certification_path][:signed_certificate_file]

      if @certification_path.save
        redirect_back(fallback_location: root_path, notice: 'The signed certificate was uploaded successfully.')
      else
        @certification_path.errors.messages.each do |field, errors|
          redirect_back(fallback_location: root_path, alert: errors.first)
          return
        end
      end
    else
      redirect_back(fallback_location: root_path, alert: 'Please select a file to upload.')
    end
  end

  def download_signed_certificate
    begin
      send_file @certification_path.signed_certificate_file.path, x_sendfile: false
    rescue ActionController::MissingFile
      redirect_back(fallback_location: root_path, alert: 'This document is no longer available for download. This could be due to a detection of malware.')
    end
  end

  def remove_signed_certificate
    begin
      @certification_path.remove_signed_certificate_file!
      @certification_path.save!

      flash[:notice] = "Certificate successfully deleted."
    rescue ActionController::MissingFile
      flash[:alert] = 'This document is failed to delete. This could be due to a detection of malware.'
    end

    redirect_back(fallback_location: root_path)
  end

  private

  def set_controller_model
    @controller_model = @certification_path
  end

  # TODO ???????????
  # def certificate_exists_and_is_allowed
  #   certificate_id = params[:certificate_id]
  #   certificate_id ||= params[:certification_path][:certificate_id]
  #   certificate = Certificate.find(certificate_id)
  #   # Verify the requested certificate exists.
  #   if certificate.nil?
  #     return redirect_to project_path(@project), alert: t('controllers.certification_paths_controller.certificate_exists_and_is_allowed.error_no_certificate')
  #   end
  #   # Verify the requested certificate is allowed to be created at this time
  #   if not @project.can_create_certification_path_for_certificate?(certificate)
  #     return redirect_to project_path(@project), alert: t('controllers.certification_paths_controller.certificate_exists_and_is_allowed.error_can_create_certificate')
  #   end
  # end

  def certification_path_params
    params.require(:certification_path).permit(:project_id, :certificate_id, :pcr_track, :expires_at, :started_at, :development_type, :appealed, :audit_log_user_comment, :audit_log_visibility)
  end

  def filepath_for_report(report_name)
    filename = "#{@project.code} - #{@certification_path.certificate.full_name} - #{report_name}.pdf"
    Rails.root.join('private', 'projects', @certification_path.project.id.to_s, 'certification_paths', @certification_path.id.to_s, 'reports', filename)
  end

end
