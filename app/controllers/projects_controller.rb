class ProjectsController < AuthenticatedController
  before_action :set_project, only: [:show, :edit, :update]
  load_and_authorize_resource

  # GET /projects
  # GET /projects.json
  def index
    @page_title = 'Projects'
    unless current_user.system_admin? || current_user.gord_manager? || current_user.gord_top_manager?
      @projects = Project.for_authorized_user current_user
    else
      @projects = Project.all
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @page_title = @project.name
    @certification_path = CertificationPath.new(project: @project)
    @project_authorization = ProjectAuthorization.new(project: @project)
  end

  # GET /projects/new
  def new
    @page_title = 'New project'
    @project = Project.new
    @certificates = Certificate.all
  end

  # GET /projects/1/edit
  def edit
    @page_title = "Edit #{@project.name}"
    @certificates = Certificate.all
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)
    @project.owner = current_user

    @project.transaction do
      if @project.save
        project_authorization = ProjectAuthorization.new(project: @project, user: current_user, role: ProjectAuthorization.roles[:project_manager])
        if project_authorization.save
          redirect_to @project, notice: 'Project was successfully created.'
          return
        end
        render :new
      else
        render :new
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      if current_user.system_admin?
        params.require(:project).permit(:name, :description, :address, :location, :country, :construction_year, :latlng, :gross_area, :certified_area, :carpark_area, :project_site_area, :terms_and_conditions_accepted, :owner_id, :code)
      else
        params.require(:project).permit(:name, :description, :address, :location, :country, :construction_year, :latlng, :gross_area, :certified_area, :carpark_area, :project_site_area, :terms_and_conditions_accepted)
      end
    end
end
