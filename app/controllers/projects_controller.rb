class ProjectsController < AuthenticatedController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /projects
  # GET /projects.json
  def index
    @page_title = 'Projects overview'
    unless current_user.system_admin?
      @projects = Project.for_user current_user
    else
      @projects = Project.all
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @page_title = 'New project'
    @project = Project.new
    @certificates = Certificate.all
  end

  # GET /projects/1/edit
  def edit
    @page_title = 'Edit project'
    @certificates = Certificate.all
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)
    @project.owner = current_user

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
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

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name, :description, :address, :location, :country, :latlng, :gross_area, :certified_area, :carpark_area, :project_site_area)
    end
end
