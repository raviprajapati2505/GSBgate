class ProjectsUsersController < AuthenticatedController
  load_and_authorize_resource
  before_action :set_project, only: [:create, :edit, :destroy, :update]
  before_action :set_projects_user, only: [:show, :edit, :destroy]

  def create
    @projects_user = ProjectsUser.new(authorizations_params)
    @projects_user.project = @project
    if @projects_user.save
      redirect_to project_path(@project), notice: 'Member was successfully added.'
    else
      redirect_to :back
    end
  end

  def edit
    @page_title = @projects_user.user.email
    if current_user.system_admin? && params.has_key?(:query) && params[:query] == 'certifiers'
      @show_certifiers = true
    end
  end

  def show
    @page_title = @projects_user.user.email
    @user = @projects_user.user
    @project = @projects_user.project
    @tasks = TaskService.instance.generate_tasks(user: @user, project_id: @project.id)
  end

  def update
    if @project.owner == @projects_user.user
      raise CanCan::AccessDenied.new('Not Authorized to edit project owner role', :update, ProjectsUser)
    end

    if @projects_user.update(authorizations_params)
      redirect_to project_path(@projects_user.project), notice: 'Authorization was successfully updated.'
    else
      render action: :edit
    end
  end

  def destroy
    if @project.owner == @projects_user.user
      raise CanCan::AccessDenied.new('Not Authorized to remove project owner from team', :destroy, ProjectsUser)
    end

    # remove user - requirement_data link
    requirement_data = @projects_user.user.requirement_data.for_project(@project)
    requirement_data.each do |requirement_datum|
      requirement_datum.user = nil
      requirement_datum.save!
    end

    # remove user - scheme_mix_criteria link
    scheme_mix_criteria = @projects_user.user.scheme_mix_criteria.for_project(@project)
    scheme_mix_criteria.each do |scheme_mix_criterion|
      scheme_mix_criterion.certifier = nil
      scheme_mix_criterion.save!
    end

    project = @projects_user.project
    @projects_user.destroy
    redirect_to project_path(project), notice: 'Member was successfully removed.'
  end

  def list_unauthorized_users
    if params.has_key?(:project_id) && params.has_key?(:q) && params.has_key?(:page)
      project = Project.find(params[:project_id])
      # .where.not('exists(select id from projects_users where user_id = users.id and project_id = ?)', params[:project_id])
      total_count = User.where('email like ?', '%' + params[:q] + '%').without_permissions_for_project(project).count
      # .where.not('exists(select id from projects_users where user_id = users.id and project_id = ?)', params[:project_id])
      items = User.select('id, email as text')
                  .where('email like ?', '%' + params[:q] + '%')
                  .order(email: :asc)
                  .paginate(page: params[:page], per_page: 25)
                  .without_permissions_for_project(project)
      render json: {total_count: total_count, items: items}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_projects_user
      @projects_user = ProjectsUser.find(params[:id])
      @controller_model = @projects_user
    end

    def authorizations_params
      params.require(:authorization).permit(:user_id, :role)
    end
end