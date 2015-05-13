class ProjectAuthorizationsController < ApplicationController
  load_and_authorize_resource
  before_action :set_project, only: [:index, :new, :create]
  before_action :set_authorization, only: [:edit, :update, :destroy]

  def index
    @project_authorizations = @project.project_authorizations
  end

  def new
    @project_authorization = ProjectAuthorization.new(project: @project)
  end

  def edit
  end

  def create
    @project_authorization = ProjectAuthorization.new(authorizations_params)
    @project_authorization.project = @project
    if @project_authorization.save
      flash[:notice] = 'Authorization was successfully created.'
      redirect_to project_project_authorizations_path
    else
      render action: :new
    end
  end

  def update
    if @project_authorization.update(authorizations_params)
      flash[:notice] = 'Authorization was successfully updated.'
      redirect_to project_project_authorizations_path
    else
      render action: :edit
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
      params.require(:authorization).permit(:user_id, :permission, :category_id)
    end
end
