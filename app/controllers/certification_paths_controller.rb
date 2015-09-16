class CertificationPathsController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path, only: [:show, :sign_certificate]
  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project

  def show
    @page_title = @certification_path.name
    @tasks = TaskService.instance.generate_tasks(user: current_user, project_id: @project.id, certification_path_id: @certification_path.id)
  end

  def new
    @certification_path = CertificationPath.new(certificate_id: params[:certificate])

    # Verify the requested certificate id is valid.
    if @certification_path.certificate.nil?
      return redirect_to project_path(@project), alert: 'Error, this certificate does not exist.'
    end

    # Verify the requested certificate is allowed to be created at this time
    if not @project.can_create_certification_path_for_certificate?(@certification_path.certificate)
      return redirect_to project_path(@project), alert: 'Error, not allowed to create this certificate.'
    end

    # Set as many generic values as possible
    @certification_path.project = @project
    @certification_path.status = :awaiting_activation

    if @certification_path.certificate.letter_of_conformance?
      @certification_path.duration = 1
      # Already provide an empty scheme_mix record to be filled in by the user
      @certification_path.scheme_mixes.build({})
    end

    if @certification_path.certificate.final_design_certificate?
      loc = @project.certification_paths.find_by(certificate: Certificate.letter_of_conformance)
      @certification_path.development_type = loc.development_type
      loc.scheme_mixes.each do |scheme_mix|
        @certification_path.scheme_mixes.build({scheme_id: scheme_mix.scheme_id, weight: scheme_mix.weight})
      end
    end

    # We have enough information to create these certificate paths automatically
    if @certification_path.certificate.construction_certificate? or @certification_path.certificate.operations_certificate?
      @certification_path.development_type = :not_applicable
      @certification_path.duration = 0
      @certification_path.scheme_mixes.build({scheme_id: @certification_path.certificate.schemes.take.id, weight: 100})
      if @certification_path.save
        return redirect_to project_path(@project), notice: 'Successfully applied for certificate.'
      else
        return redirect_to project_path(@project), alert: 'Error, could not apply for certificate.'
      end
    end
    # For the other certificate paths (LOC + FinalDesign), go to the 'new' view
  end

  def create
    @certification_path = CertificationPath.new(certification_path_params)
    @certification_path.status = :awaiting_activation
    @certification_path.project = @project
    @certification_path.certificate_id = params[:certification_path][:certificate_id]
    @certification_path.duration = params[:certification_path][:duration]
    @certification_path.development_type = params[:certification_path][:development_type]
    if @certification_path.certificate.letter_of_conformance?
      # Create the scheme_mixes
      if @certification_path.single_use?
        @certification_path.scheme_mixes.build([{scheme_id: params[:scheme_single], weight: 100}])
      else
        params[:scheme_mixed].each do |scheme_id|
          @certification_path.scheme_mixes.build([{scheme_id: scheme_id, weight: 0}])
        end
      end
    elsif @certification_path.certificate.final_design_certificate?
      loc = @project.certification_paths.find_by(certificate: Certificate.letter_of_conformance)
      @certification_path.development_type = loc.development_type
      loc.scheme_mixes.each do |scheme_mix|
        @certification_path.scheme_mixes.build({scheme_id: scheme_mix.scheme_id, weight: scheme_mix.weight})
      end
    end

    if @certification_path.save
        redirect_to(project_path(@project), notice: 'Successfully applied for certificate.')
    else
      redirect_to(project_path(@project), alert: 'Error, could not apply for certificate')
      # todo handle @certification_path.errors.
    end
  end

  def update
    CertificationPath.transaction do
      # Do some authorization/validation checks
      if @certification_path.status != certification_path_params[:status]
        case CertificationPath.statuses[certification_path_params[:status]]
          # Only system admins can set status to awaiting_submission
          when CertificationPath.statuses[:awaiting_submission]
            unless current_user.system_admin?
              raise CanCan::AccessDenied.new('Not Authorized to update certification_path status', :update, CertificationPath)
            end
          # Only project managers can set status to awaiting_screening
          when CertificationPath.statuses[:awaiting_screening]
            # all scheme mix criteria must be marked as 'complete'
            @certification_path.scheme_mix_criteria.each do |scheme_mix_criteria|
              unless scheme_mix_criteria.complete?
                @tasks = TaskService.instance.generate_tasks(user: current_user, project_id: @project.id, certification_path_id: @certification_path.id)
                flash.now[:alert] = 'All scheme mix criteria should first be completed.'
                render :show
                return
              end
            end
        end
      end

      # reset pcr_track_allowed if pcr_track is false
      if certification_path_params.has_key?(:pcr_track)
        @certification_path.pcr_track = certification_path_params[:pcr_track]
        if @certification_path.pcr_track == false
          params[:certification_path][:pcr_track_allowed] = false
        end
      end

      if @certification_path.update(certification_path_params)
        redirect_to project_certification_path_path(@project, @certification_path), notice: 'Status was successfully updated.'
      else
        @tasks = TaskService.instance.generate_tasks(user: current_user, project_id: @project.id, certification_path_id: @certification_path.id)
        render action: :show
      end
    end
  end

  def download_archive
    send_file DocumentArchiverService.instance.create_archive(@certification_path)
  end

  def sign_certificate
    if params.has_key?(:signed_by_mngr)
      @certification_path.signed_by_mngr = params[:signed_by_mngr]
      @certification_path.save!

      render json: {msg: "Certificate signed by GORD manager"} and return
    end
    if params.has_key?(:signed_by_top_mngr)
      @certification_path.signed_by_top_mngr = params[:signed_by_top_mngr]
      @certification_path.save!

      render json: {msg: "Certificate signed by GORD top manager"} and return
    end
  end

  private
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_certification_path
      @certification_path = CertificationPath.find(params[:id])
      @controller_model = @certification_path
    end

    def certification_path_params
      params.require(:certification_path).permit(:project_id, :certificate_id, :status, :signed_by_mngr, :signed_by_top_mngr, :pcr_track, :pcr_track_allowed, :duration, :started_at, :development_type)
    end
end
