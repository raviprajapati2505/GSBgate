class CertificationPathsController < AuthenticatedController
  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project
  before_action :set_controller_model, except: [:new, :create]
  before_action :certificate_exists_and_is_allowed, only: [:apply, :new, :create]

  def show
    @page_title = @certification_path.name
    @tasks = TaskService::get_tasks(page: params[:page], per_page: 25, user: current_user, project_id: @project.id, certification_path_id: @certification_path.id)
  end

  def apply
    @certification_path = CertificationPath.new(certificate_id: params[:certificate_id])
    # Set as many generic values as possible
    @certification_path.project = @project

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
            elsif @certification_path.mixed_use? or @certification_path.mixed_development? or @certification_path.mixed_development_in_stages?
              if params[:certification_path].has_key?(:schemes)
                params[:certification_path][:schemes].each do |scheme_params|
                  @certification_path.scheme_mixes.build({scheme_id: scheme_params[:scheme_id], weight: scheme_params[:weight]})
                end
              end
            end
          end
          if @certification_path.save
            return redirect_to(project_certification_path_path(@project, @certification_path), notice: 'Successfully applied for certificate.')
          else
            return redirect_to(project_certification_path_path(@project), alert: 'Error, could not apply for certificate')
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
      loc.scheme_mixes.each do |scheme_mix|
        @certification_path.scheme_mixes.build({scheme_id: scheme_mix.scheme_id, weight: scheme_mix.weight})
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
    elsif @certification_path.certificate.construction_certificate? or @certification_path.certificate.operations_certificate?
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

  def update_pcr
    CertificationPath.transaction do
      # reset pcr_track_allowed if pcr_track is false
      if certification_path_params.has_key?(:pcr_track)
        @certification_path.pcr_track = certification_path_params[:pcr_track]
        if @certification_path.pcr_track == false
          params[:certification_path][:pcr_track_allowed] = false
        end
      end

      if @certification_path.update!(certification_path_params)
        redirect_to project_certification_path_path(@project, @certification_path), notice: 'The PCR checkboxes were succesfully updated.'
      end
    end
  end

  def update_status
    if !@certification_path.can_advance_status?(current_user)
      redirect_to project_certification_path_path(@project, @certification_path), alert: 'You are not allowed to advance the certificate status at this time.'
    else
      @certification_path.appealed = certification_path_params.has_key?(:appealed)
      next_status = @certification_path.next_status
      if next_status.is_a? Integer
        @certification_path.certification_path_status_id = next_status
        @certification_path.audit_log_user_comment = params[:certification_path][:audit_log_user_comment]
        @certification_path.save!
        redirect_to project_certification_path_path(@project, @certification_path), notice: 'The certificate status was successfully updated.'
      else
        redirect_to project_certification_path_path(@project, @certification_path), alert: next_status
      end
    end
  end

  def download_archive
    send_file DocumentArchiverService.instance.create_archive(@certification_path)
  end

  def list
    render json: @project.certification_paths_optionlist
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
    params.require(:certification_path).permit(:project_id, :certificate_id, :pcr_track, :pcr_track_allowed, :duration, :started_at, :development_type, :appealed)
  end
end
