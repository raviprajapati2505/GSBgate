class ProjectAuthorizationsController < AuthenticatedController
  load_and_authorize_resource
  before_action :set_project, only: [:new, :create]
  before_action :set_authorization, only: [:destroy]

  def new
    authorize! :manage, @project
    @project_authorization = ProjectAuthorization.new(project: @project)
  end

  def create
    authorize! :manage, @project
    @project_authorization = ProjectAuthorization.new(authorizations_params)
    @project_authorization.project = @project
    if @project_authorization.save
      flash[:notice] = 'Member was successfully added.'
      redirect_to project_path id: @project.id
    else
      render action: :new
    end
  end

  def destroy
    @project_authorization.destroy
    flash[:notice] = 'Authorization was successfully destroyed.'
    redirect_to project_project_authorizations_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_authorization
      @project_authorization = ProjectAuthorization.find(params[:id])
    end

    def authorizations_params
      params.require(:authorization).permit(:user_id, :role)
    end
end
