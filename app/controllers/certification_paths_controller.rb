class CertificationPathsController < AuthenticatedController
  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project

  before_action :set_controller_model, except: [:new, :create, :list]
  before_action :certificate_exists_and_is_allowed, only: [:apply, :new, :create]

  def show
    respond_to do |format|
      format.html {
        @page_title = @certification_path.name
        @tasks = TaskService::get_tasks(page: params[:page], per_page: 25, user: current_user, project_id: @project.id, certification_path_id: @certification_path.id)
      }
      format.json { render json: {id: @certification_path.id, name: @certification_path.name}, status: :ok }
    end
  end

  def apply
    @certification_path = CertificationPath.new(certificate_id: params[:certificate_id])
    @certification_path.project = @project
    authorize! :apply, @certification_path

    # LOC
    if @certification_path.certificate.letter_of_conformance?
      @certification_path.duration = 1
      # show the modal, so the user can enter certification_path details
      respond_to do |format|
        format.js {
          return render 'apply'
        }
        format.html {
          if params.has_key?(:certification_path)
            if params[:certification_path].has_key?(:pcr_track)
              @certification_path.pcr_track = params[:certification_path][:pcr_track]
            end
            if params[:certification_path].has_key?(:development_type)
              @certification_path.development_type = params[:certification_path][:development_type]
            end
            if @certification_path.single_use?
              if params.has_key?(:single_scheme_select)
                @certification_path.scheme_mixes.build({scheme_id: params[:single_scheme_select], weight: 100})
              end
            elsif @certification_path.mixed?
              if params[:certification_path].has_key?(:schemes)
                params[:certification_path][:schemes].each do |scheme_params|
                  if scheme_params[:custom_name].blank?
                    scheme_params[:custom_name] = nil
                  end
                  @certification_path.scheme_mixes.build({scheme_id: scheme_params[:scheme_id], weight: scheme_params[:weight], custom_name: scheme_params[:custom_name]})
                end
              end
            end
          end
          if @certification_path.save
            return redirect_to(project_certification_path_path(@project, @certification_path), notice: 'Successfully applied for certificate.')
          else
            return redirect_to(project_path(@project), alert: 'Error, could not apply for certificate.')
          end
        }
      end
    elsif @certification_path.certificate.final_design_certificate?
      if params.has_key?(:certification_path)
        if params[:certification_path].has_key?(:pcr_track)
          @certification_path.pcr_track = params[:certification_path][:pcr_track]
        end
        if params[:certification_path].has_key?(:duration)
          @certification_path.duration = params[:certification_path][:duration]
        end
      end
      loc = @project.certification_paths.find_by(certificate: Certificate.letter_of_conformance)
      @certification_path.development_type = loc.development_type
      # Final Design Certificate version must be equal to Letter Of Conformance version
      @certification_path.certificate = Certificate.final_design_certificate.where(gsas_version: loc.certificate.gsas_version).first
      # Mirror the LOC scheme mixes
      loc.scheme_mixes.each do |scheme_mix|
        new_scheme_mix = @certification_path.scheme_mixes.build({scheme_id: scheme_mix.scheme_id, weight: scheme_mix.weight, custom_name: scheme_mix.custom_name})
        # Mirror the main scheme mix
        if loc.main_scheme_mix_id.present? && (scheme_mix.id == loc.main_scheme_mix_id)
          @certification_path.main_scheme_mix = new_scheme_mix
          @certification_path.main_scheme_mix_selected = true
        end
      end
      # show the modal, so the user can enter certification_path details
      respond_to do |format|
        format.js {
          return render 'apply'
        }
        format.html {
          if @certification_path.save
            return redirect_to(project_certification_path_path(@project, @certification_path), notice: 'Successfully applied for certificate.')
          else
            return redirect_to(project_path(@project), alert: 'Error, could not apply for certificate')
          end
        }
      end
    elsif @certification_path.certificate.construction_certificate? || @certification_path.certificate.operations_certificate?
      @certification_path.development_type = :not_applicable
      @certification_path.duration = 0
      @certification_path.scheme_mixes.build({scheme_id: @certification_path.certificate.schemes.take.id, weight: 100})
      if params.has_key?(:certification_path)
        if params[:certification_path].has_key?(:pcr_track)
          @certification_path.pcr_track = params[:certification_path][:pcr_track]
        end
      end
      respond_to do |format|
        format.js {
          return render 'apply'
        }
        format.html {
          if @certification_path.save
            return redirect_to(project_certification_path_path(@project, @certification_path), notice: 'Successfully applied for certificate.')
          else
            return redirect_to(project_path(@project), alert: 'Error, could not apply for certificate')
          end
        }
      end
    end
  end

  def apply_for_pcr
    if @certification_path.update!(:pcr_track => true)
      redirect_to project_certification_path_path(@project, @certification_path), notice: 'Successfully applied for PCR track'
    end
  end

  def approve_pcr_payment
    if @certification_path.update!(:pcr_track_allowed => true)
      redirect_to project_certification_path_path(@project, @certification_path), notice: 'Approved PCR payment'
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
        @certification_path.save!

        # If there was an appeal, set the status of the selected criteria to 'Appealed'
        if certification_path_params.has_key?(:appealed) && params.has_key?(:scheme_mix_criterion)
          params[:scheme_mix_criterion].each do |smc_id|
            SchemeMixCriterion.find(smc_id.to_i).appealed!
          end
        end
        redirect_to project_certification_path_path(@project, @certification_path), notice: 'The certificate status was successfully updated.'
      else
        redirect_to project_certification_path_path(@project, @certification_path), alert: todos.first
      end
    end
  end

  def download_archive
    temp_file = Tempfile.new(request.remote_ip)
    DocumentArchiverService.instance.create_archive(@certification_path, temp_file)
    send_file temp_file.path, type: 'application/zip', disposition: 'attachment', filename: sanitize_filename(@certification_path.project.name + ' - ' + @certification_path.name) + ' - ' + Time.new.strftime(I18n.t('time.formats.filename'))  + '.zip'
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
    @page_title = 'Allocate project team responsibility for ' + @certification_path.name
  end

  def edit_certifier_team_responsibility
    @page_title = 'Allocate certifier team responsibility for ' + @certification_path.name
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

  private

  def set_controller_model
    @controller_model = @certification_path
  end

  def certificate_exists_and_is_allowed
    certificate_id = params[:certificate_id]
    certificate_id ||= params[:certification_path][:certificate_id]
    certificate = Certificate.find(certificate_id)
    # Verify the requested certificate exists.
    if certificate.nil?
      return redirect_to project_path(@project), alert: 'Error, this certificate does not exist.'
    end
    # Verify the requested certificate is allowed to be created at this time
    if not @project.can_create_certification_path_for_certificate?(certificate)
      return redirect_to project_path(@project), alert: 'Error, not allowed to create this certificate.'
    end
  end

  def certification_path_params
    params.require(:certification_path).permit(:project_id, :certificate_id, :pcr_track, :pcr_track_allowed, :duration, :started_at, :development_type, :appealed, :audit_log_user_comment)
  end

  def sanitize_filename(name)
    name.gsub!(/[^a-zA-Z0-9\.\-\+_ ]/, '_')
    name = "_#{name}" if name =~ /^\.+$/
    name
  end
end
