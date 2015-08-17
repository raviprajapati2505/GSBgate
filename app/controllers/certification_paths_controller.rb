class CertificationPathsController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path, only: [:show]
  load_and_authorize_resource

  def show
    @page_title = "#{@certification_path.certificate.label} for #{@project.name}"
  end

  def create
    @certification_path = CertificationPath.new(certification_path_params)
    @certification_path.status = :registered
    @certification_path.project = @project
    if @certification_path.save
        # Generate a notification for the system admins
        User.system_admin.each do |system_admin|
          notify(body: 'A new application for a %s was created.',
                 body_params: [@certification_path.certificate.label],
                 uri: project_path(@project),
                 user: system_admin,
                 project: @project)
        end
        redirect_to project_path(@project), notice: 'Successfully applied for certificate.'
    else
      redirect_to project_path(@project), notice: 'Error, could not apply for certificate'
      # todo handle @certification_path.errors.
    end
  end

  def update
    CertificationPath.transaction do
      if @certification_path.status != certification_path_params[:status]
        case CertificationPath.statuses[certification_path_params[:status]]
          when CertificationPath.statuses[:in_submission]
            unless current_user.system_admin?
              raise CanCan::AccessDenied.new('Not Authorized to update certification_path status', :update, CertificationPath)
            end
            # Generate a notification for the project owner
            notify(body: 'The status of %s was changed to %s.',
                   body_params: [@certification_path.certificate.label, certification_path_params[:status].humanize],
                   uri: project_certification_path_path(@project, @certification_path),
                   user: @project.owner,
                   project: @project)
          when CertificationPath.statuses[:in_screening]
            # all scheme mix criteria must be marked as 'complete'
            @certification_path.scheme_mix_criteria.each do |scheme_mix_criteria|
              unless scheme_mix_criteria.complete?
                flash.now[:alert] = 'All scheme mix criteria should first be completed.'
                render :show
                return
              end
            end

            # Generate a notification for the certifier managers
            ProjectAuthorization.for_project(@project).certifier_manager.each do |project_authorization|
              notify(body: 'The status of %s was changed to %s.',
                     body_params: [@certification_path.certificate.label, certification_path_params[:status].humanize],
                     uri: project_certification_path_path(@project, @certification_path),
                     user: project_authorization.user,
                     project: @project)
            end
        end
      end
      if @certification_path.update(certification_path_params)
        if @certification_path.scheme_mixes.empty?
          @certification_path.create_descendant_records
          redirect_to project_certification_path_path(@project, @certification_path), notice: 'Status was successfully updated.'
        end
      else
        render action: :show
      end
    end
  end

  def download_archive
    send_file DocumentArchiverService.instance.create_archive(@certification_path.scheme_mix_criteria_documents.approved)
  end

  private
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_certification_path
      @certification_path = CertificationPath.find(params[:id])
    end

    def certification_path_params
      params.require(:certification_path).permit(:certificate_id, :status)
    end
end
