class CertificationPathsController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path, only: [:show, :edit]
  load_and_authorize_resource

  def index
    @certification_paths = CertificationPath.all
  end

  def show
    if @certification_path.scheme_mixes.count == 1
      redirect_to project_certification_path_scheme_mix_path(@project, @certification_path, @certification_path.scheme_mixes.take)
    end
    @page_title = "#{@certification_path.certificate.label} for #{@project.name}"
  end

  def new
    authorize! :manage, @project
    @certification_path = CertificationPath.new(project: @project)
  end

  def create
    authorize! :manage, @project
    @certification_path = CertificationPath.new(certification_path_params)
    @certification_path.registered!
    @certification_path.project = @project
    if @certification_path.certificate_id == Certificate.where('label = ?', 'Operations Certificate').first.id
      if @certification_path.save
        flash[:notice] = 'Successfully applied for certificate.'
        redirect_to project_path(@project)
      else
        render action: :new
      end
    else
      flash[:alert] = 'This certificate is not yet available.'
      render action: :new
    end
  end

  def edit

  end

  def update
    CertificationPath.transaction do
      if @certification_path.status != certification_path_params[:status]
        if !current_user.system_admin?
          raise CanCan::AccessDenied.new('Not Authorized to update certification_path status', :update, CertificationPath)
        end
        # Generate a notification for the project owner
        Notification.create(body: 'The status of "' + @certification_path.certificate.label + '" was changed.', uri: project_certification_path_path(@project, @certification_path), user: project.owner, project: @project)
      end
      if @certification_path.update(certification_path_params)
        if @certification_path.scheme_mixes.count == 0
          SchemeMix.create(certification_path_id: @certification_path.id, scheme_id: Scheme.where('label = ?', 'Operations').first.id, weight: 100)
        end
        flash[:notice] = 'Status was successfully updated.'
        redirect_to edit_project_certification_path_path(@project, @certification_path)
      else
        render action: :edit
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
