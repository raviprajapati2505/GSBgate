class ProjectsUsersController < AuthenticatedController
  load_and_authorize_resource :project, except: [:list_users_sharing_projects, :list_projects]
  load_and_authorize_resource :projects_user, :through => :project, param_method: :authorizations_params, except: [:list_users_sharing_projects, :list_projects]
  skip_authorization_check only: [:list_users_sharing_projects, :list_projects]
  before_action :set_controller_model, except: [:new, :create, :available, :list_users_sharing_projects, :list_projects]

  def create
    @projects_user = ProjectsUser.new(authorizations_params)
    @projects_user.project = @project
    if @projects_user.save
      DigestMailer.added_to_project_email(@projects_user).deliver_now
      redirect_to project_path(@project), notice: 'Member was successfully added.'
    else
      redirect_to :back, alert: 'All fields are required'
    end
  end

  def edit
    @page_title = @projects_user.user.email
    if (current_user.system_admin? || current_user.gord_admin?) && params.has_key?(:query) && params[:query] == 'certifiers'
      @show_certifiers = true
    end
  end

  def show
    @page_title = @projects_user.user.email
    @user = @projects_user.user
    @project = @projects_user.project
    @tasks = TaskService::get_tasks(page: params[:page], per_page: 25, user: @user, project_id: @project.id)
  end

  def update
    if @project.owner == @projects_user.user
      raise CanCan::AccessDenied.new('Not Authorized to edit project owner role', :update, ProjectsUser)
    end

    if @projects_user.update(authorizations_params)
      DigestMailer.updated_role_email(@projects_user).deliver_now
      redirect_to project_path(@projects_user.project), notice: 'Authorization was successfully updated.'
    else
      render action: :edit
    end
  end

  def make_owner
    begin
      @project.transaction do
        # change project role to project manager
        @projects_user.role = ProjectsUser.roles[:project_manager]
        @projects_user.save!
        # change project owner
        @project.owner = @projects_user.user
        @project.save!
      end
      redirect_to project_path(@projects_user.project), notice: 'Project owner was successfully updated.'
    rescue Exception
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

    # remove user - notification_type link
    user = @projects_user.user
    if user.user?
      NotificationTypesUser.delete_all(user_id: user.id, project_id: @projects_user.project.id)
    end

    project = @projects_user.project
    @projects_user.destroy
    DigestMailer.removed_from_project_email(@projects_user).deliver_now
    redirect_to project_path(project), notice: 'Member was successfully removed.'
  end

  # Returns all users still available to be assigned to a project
  # Can optionally be filtered by role and email
  def available
    # Filter by Role
    if params.has_key?(:role)
      case params[:role].to_sym
        when :assessor
          users = User.assessors
        when :certifier
          users = User.certifiers
        when :enterprise_client
          users = User.enterprise_clients
        else
          users = User.all
      end
    else
      users = User.all
    end
    # Filter by text in email field
    users = users.search_email(params[:q]) if params.has_key?(:q)
    # Filter out users already in project
    project_user_ids = @projects_users.collect{|project_user| project_user.user_id}
    users = users.where.not(id: project_user_ids)
    # Paginate
    if params.has_key?(:page)
      users = users.page(params[:page])
      total_count = users.total_entries
    else
      total_count = users.count
    end
    render json: {total_count: total_count, items: users.select('id, email as text')}
  end

  def list_users_sharing_projects
    if params.has_key?(:user_id) && params.has_key?(:q) && params.has_key?(:page)
      if params[:user_id] == current_user.id.to_s
        if current_user.system_admin? || current_user.gord_top_manager? || current_user.gord_manager? || current_user.gord_admin?
          total_count = User.where('email like ?', '%' + params[:q] + '%')
                            .count
          items = User.select('id, email as text')
                      .where('email like ?', '%' + params[:q] + '%')
                      .page(params[:page]).per(25)
        else
          user = User.arel_table
          projects_user = ProjectsUser.arel_table
          join_on = user.create_on(user[:id].eq(projects_user[:user_id]))
          outer_join = user.create_join(projects_user, join_on, Arel::Nodes::OuterJoin)

          total_count = User.distinct
                            .joins(outer_join)
                            .where('email like ? ', '%' + params[:q] + '%')
                            .where('users.role <> 1 OR projects_users.project_id in (select pu.project_id from projects_users pu where pu.user_id = ?)', current_user.id)
                            .count
          items = User.select('users.id as id, users.email as text')
                      .distinct
                      .joins(outer_join)
                      .where('email like ? ', '%' + params[:q] + '%')
                      .where('users.role <> 1 OR projects_users.project_id in (select pu.project_id from projects_users pu where pu.user_id = ?)', current_user.id)
                      .page(params[:page]).per(25)
        end
        render json: {total_count: total_count, items: items} and return
      end
    end
  end

  def list_projects
    if params.has_key?(:q) && params.has_key?(:page)
      if current_user.system_admin? || current_user.gord_top_manager? || current_user.gord_manager? || current_user.gord_admin?
        total_count = Project.where('name like ?', '%' + params[:q] + '%').count
        items = Project.select('id, name as text, projects.code as code, projects.latlng as latlng')
                    .where('name like ?', '%' + params[:q] + '%')
                    .page(params[:page]).per(25)
      else
        project = Project.arel_table
        projects_user = ProjectsUser.arel_table
        join_on = project.create_on(project[:id].eq(projects_user[:project_id]))
        outer_join = project.create_join(projects_user, join_on, Arel::Nodes::OuterJoin)

        total_count = Project.distinct
                          .joins(outer_join)
                          .where('name like ?', '%' + params[:q] + '%')
                          .where('projects_users.user_id = ?', current_user.id)
                          .count
        items = Project.select('projects.id as id, projects.name as text, projects.code as code, projects.latlng as latlng')
                    .distinct
                    .joins(outer_join)
                    .where('name like ?', '%' + params[:q] + '%')
                    .where('projects_users.user_id = ?', current_user.id)
                    .page(params[:page]).per(25)
      end
      render json: {total_count: total_count, items: items}, status: :ok
    end
  end

  private
    def set_controller_model
      @controller_model = @projects_user
    end

    def authorizations_params
      params.require(:authorization).permit(:user_id, :role)
    end
end
