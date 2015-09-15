class CertificationPathsController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path, only: [:show, :sign_certificate]
  load_and_authorize_resource

  def show
    @page_title = @certification_path.name
    @tasks = TaskService.instance.generate_tasks(user: current_user, project_id: @project.id, certification_path_id: @certification_path.id)
  end

  def create
    @certification_path = CertificationPath.new(certification_path_params)
    @certification_path.status = :registered
    @certification_path.project = @project
    if @certification_path.save
        redirect_to project_path(@project), notice: 'Successfully applied for certificate.'
    else
      redirect_to project_path(@project), notice: 'Error, could not apply for certificate'
      # todo handle @certification_path.errors.
    end
  end

  def update
    CertificationPath.transaction do
      # Do some authorization/validation checks
      if @certification_path.status != certification_path_params[:status]
        case CertificationPath.statuses[certification_path_params[:status]]
          # Only system admins can set status to in_submission
          when CertificationPath.statuses[:in_submission]
            unless current_user.system_admin?
              raise CanCan::AccessDenied.new('Not Authorized to update certification_path status', :update, CertificationPath)
            end
          # Only project managers can set status to in_screening
          when CertificationPath.statuses[:in_screening]
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
        if @certification_path.scheme_mixes.empty?
          @certification_path.create_descendant_records
        end
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
      params.require(:certification_path).permit(:certificate_id, :status, :pcr_track, :pcr_track_allowed)
    end
end
