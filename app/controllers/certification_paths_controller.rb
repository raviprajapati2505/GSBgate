class CertificationPathsController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path, only: [:show]
  load_and_authorize_resource

  def show
    @page_title = "#{@certification_path.certificate.label} for #{@project.name}"
  end

  def create
    @certification_path = CertificationPath.new(certification_path_params)
    @certification_path.registered!
    @certification_path.project = @project
    if @certification_path.certificate_id == Certificate.where('label = ?', 'Operations Certificate').first.id
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
        redirect_to :back
      end
    else
      redirect_to :back, alert: 'This certificate is not yet available.'
    end
  end

  def update
    CertificationPath.transaction do
      if @certification_path.status != certification_path_params[:status]
        case CertificationPath.statuses[certification_path_params[:status]]
          when CertificationPath.statuses[:preassessment]
            unless current_user.system_admin?
              raise CanCan::AccessDenied.new('Not Authorized to update certification_path status', :update, CertificationPath)
            end
            # Generate a notification for the project owner
            notify(body: 'The status of %s was changed to %s.',
                   body_params: [@certification_path.certificate.label, certification_path_params[:status].humanize],
                   uri: project_certification_path_path(@project, @certification_path),
                   user: @project.owner,
                   project: @project)
          when CertificationPath.statuses[:preliminary]
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
        if @certification_path.scheme_mixes.count == 0
          SchemeMix.create(certification_path_id: @certification_path.id, scheme_id: Scheme.where('label = ?', 'Operations').first.id, weight: 100)
        end
        redirect_to project_certification_path_path(@project, @certification_path), notice: 'Status was successfully updated.'
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
