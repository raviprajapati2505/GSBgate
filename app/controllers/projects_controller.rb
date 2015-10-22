class ProjectsController < AuthenticatedController
  load_and_authorize_resource :project
  before_action :set_controller_model, except: [:new, :create, :index]

  # GET /projects
  # GET /projects.json
  def index
    @page_title = 'Projects'
    unless current_user.system_admin? || current_user.gord_manager? || current_user.gord_top_manager?
      @projects = @projects.for_user(current_user)
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    respond_to do |format|
      format.html {
        @page_title = @project.name
        @certification_path = CertificationPath.new(project: @project)
        @projects_user = ProjectsUser.new(project: @project)
      }
      format.json { render json: @project, status: :ok }
    end
  end

  def show_tools
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
        projects_user = ProjectsUser.new(project: @project, user: current_user, role: ProjectsUser.roles[:project_manager])
        if projects_user.save
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
      params[:project][:location_plan_file] = @project.location_plan_file unless params[:project].has_key?(:location_plan_file) && params[:project][:location_plan_file].present?
      params[:project][:site_plan_file] = @project.site_plan_file unless params[:project].has_key?(:site_plan_file) && params[:project][:site_plan_file].present?
      params[:project][:design_brief_file] = @project.design_brief_file unless params[:project].has_key?(:design_brief_file) && params[:project][:design_brief_file].present?
      params[:project][:project_narrative_file] = @project.project_narrative_file unless params[:project].has_key?(:project_narrative_file) && params[:project][:project_narrative_file].present?

      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def download_location_plan
    send_file @project.location_plan_file.path
  end

  def download_site_plan
    send_file @project.site_plan_file.path
  end

  def download_design_brief
    send_file @project.design_brief_file.path
  end

  def download_project_narrative
    send_file @project.project_narrative_file.path
  end

  private
    def set_controller_model
      @controller_model = @project
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      if current_user.system_admin?
        params.require(:project).permit(:name, :description, :address, :location, :country, :construction_year, :latlng, :gross_area, :certified_area, :carpark_area, :project_site_area, :terms_and_conditions_accepted, :location_plan_file, :site_plan_file, :design_brief_file, :project_narrative_file, :owner_id, :code)
      else
        params.require(:project).permit(:name, :description, :address, :location, :country, :construction_year, :latlng, :gross_area, :certified_area, :carpark_area, :project_site_area, :terms_and_conditions_accepted, :location_plan_file, :site_plan_file, :design_brief_file, :project_narrative_file)
      end
    end
end
