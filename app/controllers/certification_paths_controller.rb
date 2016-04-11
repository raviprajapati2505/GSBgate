class CertificationPathsController < AuthenticatedController
  include ActionView::Helpers::TranslationHelper
  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project

  before_action :set_controller_model, except: [:new, :create, :list]
  # TODO ???????????
  # before_action :certificate_exists_and_is_allowed, only: [:apply, :new, :create]

  def show
    respond_to do |format|
      format.html {
        @page_title = ERB::Util.html_escape(@certification_path.name.to_s)
        @tasks = TaskService::get_tasks(page: params[:page], per_page: 25, user: current_user, project_id: @project.id, certification_path_id: @certification_path.id)
      }
      format.json { render json: {id: @certification_path.id, name: @certification_path.name}, status: :ok }
    end
  end

  def apply
    # create a new object, for our project
    @certification_path = CertificationPath.new(project_id: @project.id)
    # check if the user is authorized to apply for a new certification_path in out project
    authorize! :apply, @certification_path

    # To determine the certificate, we need both the certification_type and the gsas_version
    #  - The certification_type is passed as part of the url
    #  TODO: verify 'certification_type', as it is a required param !
    @certification_type = Certificate.certification_types.key(params[:certification_type].to_i)

    # Note: FinalDesign reuses the version from LetterOfConformance !!
    if Certificate.certification_types[@certification_type] == Certificate.certification_types[:final_design_certificate]
      @gsas_version = @certification_path.project.completed_letter_of_conformances.first.certificate.gsas_version
    else
      #  - The gsas_version can be passed as post data, but we also provide a default based on the available data
      #  TODO: verify 'gsas_version' is valid
      @gsas_versions = Certificate.with_certification_type(Certificate.certification_types[@certification_type]).order(gsas_version: :desc).distinct.pluck(:gsas_version, :gsas_version)
      if params.has_key?(:gsas_version)
        @gsas_version = params[:gsas_version]
      else
        @gsas_version = @gsas_versions.first
      end
    end

    #  - Determine the resulting certificate, and add it to our certification_path
    #  TODO: verify there is only 1 certificate
    @certificates = Certificate.with_gsas_version(@gsas_version).with_certification_type(Certificate.certification_types[@certification_type])
    @certification_path.certificate = @certificates.first

    # PCR Track
    if params.has_key?(:certification_path) && params[:certification_path].has_key?(:pcr_track)
      @certification_path.pcr_track = params[:certification_path][:pcr_track]
    else
      @certification_path.pcr_track = false
    end

    # Duration
    if @certification_path.certificate.letter_of_conformance?
      @certification_path.duration = 1
    elsif @certification_path.certificate.final_design_certificate?
      @durations = [['2 years', 2], ['3 years', 3], ['4 years', 4]]
      if params.has_key?(:certification_path) && params[:certification_path].has_key?(:duration)
        @certification_path.duration = params[:certification_path][:duration]
      else
        @certification_path.duration = @durations.first[1]
      end
    else
      @certification_path.duration = 0
    end

    # Development Type
    # Note: FinalDesign uses a similar DevelopmentType as Letter Of Conformace !!
    if Certificate.certification_types[@certification_type] == Certificate.certification_types[:final_design_certificate]
      # Note: we currently use the name to match, this coul be done cleaner
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
        new_scheme_mix = @certification_path.scheme_mixes.build({scheme_id: scheme_mix.scheme_id, weight: scheme_mix.weight, custom_name: scheme_mix.custom_name})
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
    if @certification_path.update!(:pcr_track => false, :pcr_track_allowed => false)
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
        @certification_path.appealed = certification_path_params.has_key?(:appealed)

        # Retrieve & save the next status
        @certification_path.certification_path_status_id = @certification_path.next_status
        @certification_path.audit_log_user_comment = params[:certification_path][:audit_log_user_comment]
        @certification_path.audit_log_visibility =  params[:certification_path][:audit_log_visibility]
        @certification_path.save!

        # If there was an appeal, set the status of the selected criteria to 'Appealed'
        if certification_path_params.has_key?(:appealed) && params.has_key?(:scheme_mix_criterion)
          params[:scheme_mix_criterion].each do |smc_id|
            SchemeMixCriterion.find(smc_id.to_i).appealed!
          end
        end
        redirect_to project_certification_path_path(@project, @certification_path), notice: t('controllers.certification_paths_controller.update_status.notice_success')
      else
        redirect_to project_certification_path_path(@project, @certification_path), alert: todos.first
      end
    end
  end

  def download_archive
    temp_file = Tempfile.new(request.remote_ip)
    DocumentArchiverService.instance.create_archive(@certification_path, temp_file)
    send_file temp_file.path, type: 'application/zip', disposition: 'attachment', filename: sanitize_filename(@certification_path.project.name + ' - ' + @certification_path.name) + ' - ' + Time.new.strftime(t('time.formats.filename'))  + '.zip'
    temp_file.close
  end

  def list
    total_count = CertificationPath.joins(:certificate)
                      .where(project_id: @project.id)
                      .where('certificates.name like ?', '%' + params[:q] + '%')
                      .count
    items = CertificationPath.select('certification_paths.id as id, CONCAT(certificates.name, \' \', certificates.gsas_version) as text, certification_paths.certification_path_status_id')
                .joins(:certificate)
                .where(project_id: @project.id)
                .where('certificates.name like ?', '%' + params[:q] + '%')
                .page(params[:page]).per(25)
    render json: {total_count: total_count, items: items}
  end

  def edit_project_team_responsibility
    @page_title = t('controllers.certification_paths_controller.edit_project_team_responsibility.page_title', certificate: @certification_path.name)
  end

  def edit_certifier_team_responsibility
    @page_title = t('controllers.certification_paths_controller.edit_certifier_team_responsibility.page_title', certificate: @certification_path.name)
  end

  def allocate_project_team_responsibility
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
      redirect_to edit_project_team_responsibility_project_certification_path_path
    else
      redirect_to project_certification_path_path
    end
  end

  def allocate_certifier_team_responsibility
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
      redirect_to edit_certifier_team_responsibility_project_certification_path_path
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
    flash[:notice] = 'The maximum number of PCR reviews is saved succesfullly.'
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
  #
  # def download_coverletter_report
  #   filepath = filepath_for_report 'Cover Letter'
  #   # if not File.exists?(filepath)
  #   report = Reports::LetterOfConformanceCoverLetter.new(@certification_path)
  #   report.save_as(filepath)
  #   # end
  #   send_file filepath, :type => 'application/pdf', :x_sendfile => true
  # end
  #
  # def download_scores_report
  #   filepath = filepath_for_report 'Criteria Score v2.1'
  #   # if not File.exists?(filepath)
  #   report = Reports::CriteriaScores.new(@certification_path)
  #   report.save_as(filepath)
  #   # end
  #   send_file filepath, :type => 'application/pdf', :x_sendfile => true
  # end

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
    params.require(:certification_path).permit(:project_id, :certificate_id, :pcr_track, :duration, :started_at, :development_type, :appealed, :audit_log_user_comment, :audit_log_visibility)
  end

  def sanitize_filename(name)
    name.gsub!(/[^a-zA-Z0-9\.\-\+_ ]/, '_')
    name = "_#{name}" if name =~ /^\.+$/
    name
  end

  def filepath_for_report(report_name)
    filename = "#{@certification_path.certificate.full_name} #{report_name}.pdf"
    Rails.root.join('private', 'projects', @certification_path.project.id.to_s, 'certification_paths', @certification_path.id.to_s, 'reports', filename)
  end

end
