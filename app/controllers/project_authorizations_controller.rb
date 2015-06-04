class ProjectAuthorizationsController < AuthenticatedController
  load_and_authorize_resource
  before_action :set_project, only: [:index, :new, :create, :update_permissions, :destroy_permissions]
  before_action :set_authorization, only: [:edit, :update, :destroy]

  # def index
  #   @page_title = "Project #{@project.name}"
  #   @categories = Category.all
  # end

  def new
    @project_authorization = ProjectAuthorization.new(project: @project)
  end

  # def edit
  # end

  def create
    @project_authorization = ProjectAuthorization.new(authorizations_params)
    @project_authorization.project = @project
    @project_authorization.permission = :read_only
    if @project_authorization.save
      flash[:notice] = 'Member was successfully added.'
      redirect_to project_path id: @project.id
    else
      render action: :new
    end
  end

  # def update
  #   if @project_authorization.update(authorizations_params)
  #     flash[:notice] = 'Authorization was successfully updated.'
  #     redirect_to project_project_authorizations_path
  #   else
  #     render action: :edit
  #   end
  # end

  def destroy
    @project_authorization.destroy
    flash[:notice] = 'Authorization was successfully destroyed.'
    redirect_to project_project_authorizations_path
  end

  # def update_permissions
  #   ProjectAuthorization.transaction do
  #     # reset all project permissions to read-only
  #     @project.users.distinct.each do |user|
  #       # delete all category specific permissions
  #       ProjectAuthorization.where.not(category_id: nil).delete_all(project: @project, user: user)
  #       # reset the rest to read-only
  #       ProjectAuthorization.where(project: @project, user: user, category_id: nil).update_all(permission: :read_only)
  #     end
  #     if not params[:permission].nil?
  #       # loop over project team members with manage permission or at least 1 read_write permission
  #       params[:permission].each do |user_id, category_permission|
  #         if category_permission.any? { |k, v| k == 'pm' }
  #           # set manager permission
  #           ProjectAuthorization.where(project: @project, user_id: user_id, category_id: nil).update_all(permission: 2)
  #         else
  #           # set read_write permission per category
  #           category_permission.each do |category_id, permission|
  #             ProjectAuthorization.create(project: @project, user_id: user_id, category_id: category_id, permission: :read_write)
  #           end
  #         end
  #       end
  #     end
  #     flash[:notice] = 'Permissions successfully updated.'
  #     redirect_to project_project_authorizations_path
  #   end
  # end

  # def destroy_permissions
  #   ProjectAuthorization.delete_all(project: @project, user_id: params[:user_id])
  #   flash[:notice] = 'Permissions successfully destroyed.'
  #   redirect_to project_project_authorizations_path
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_authorization
      @project_authorization = ProjectAuthorization.find(params[:id])
    end

    def authorizations_params
      params.require(:authorization).permit(:user_id)
    end
end
