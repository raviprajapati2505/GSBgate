class ProjectsUsersController < AuthenticatedController
  include ActionView::Helpers::TextHelper

  load_and_authorize_resource :project, except: [:list_users_sharing_projects, :list_projects]
  load_and_authorize_resource :projects_user, :through => :project, except: [:create, :list_users_sharing_projects, :list_projects]
  skip_authorization_check only: [:create, :list_users_sharing_projects, :list_projects]
  before_action :set_controller_model, except: [:create, :list_users_sharing_projects, :list_projects]

  def create
    notices = []

    # Create ProjectUser records for existing users
    if params.has_key?(:projects_users)
      projects_users = []

      ProjectsUser.transaction do
        params[:projects_users].each do |pu|
          # Create the model
          projects_user = ProjectsUser.new
          projects_user.user_id = pu[:user_id]
          projects_user.role = pu[:role]
          projects_user.project = @project

          # Check ability & gord_employee flag
          if can?(:create, projects_user) && (!projects_user.gsas_trust_team? || projects_user.user.gord_employee?)
            projects_user.save!
            projects_users << projects_user
          end
        end
      end

      # Notify new members by email
      projects_users.each do |pu|
        DigestMailer.added_to_project_email(pu).deliver_now
      end

      if (projects_users.count > 0)
        notices << pluralize(projects_users.count, 'user was', 'users were') + ' added to the team.'
      end
    end

    # Invite new users to linkme.qa by email
    if params.has_key?(:emails)
      params[:emails].each do |email|
        DigestMailer.linkme_invitation_email(email, current_user).deliver_now
      end

      if (params[:emails].count > 0)
        notices << pluralize(params[:emails].count, 'user was', 'users were') + ' invited to linkme.qa.'
      end
    end

    # Set flash message
    if (notices.count > 0)
      flash[:notice] = notices.join('<br />')
    else
      flash[:alert] = 'No users were added.'
    end

    redirect_to project_path(@project)
  end

  def edit
    @page_title = ERB::Util.html_escape(@projects_user.user.full_name)
  end

  def show
    @page_title = ERB::Util.html_escape(@projects_user.user.full_name)
    @user = @projects_user.user
    @project = @projects_user.project
    @tasks = TaskService::get_tasks(page: params[:page], per_page: 25, user: @user, project_id: @project.id)
  end

  def update
    if @projects_user.update(projects_user_params)
      DigestMailer.updated_role_email(@projects_user).deliver_now
      redirect_to project_path(@projects_user.project), notice: 'Authorization was successfully updated.'
    else
      render action: :edit
    end
  end

  def destroy
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
    NotificationTypesUser.delete_all(user_id: user.id, project_id: @projects_user.project.id)

    project = @projects_user.project
    @projects_user.destroy
    DigestMailer.removed_from_project_email(@projects_user).deliver_now
    redirect_to project_path(project), notice: 'Member was successfully removed.'
  end

  def list_users_sharing_projects
    if params.has_key?(:user_id) && params.has_key?(:q) && params.has_key?(:page)
      if params[:user_id] == current_user.id.to_s
        if current_user.system_admin? || current_user.gsas_trust_top_manager? || current_user.gsas_trust_manager? || current_user.gsas_trust_admin?
          total_count = User.where('name like ?', '%' + params[:q] + '%')
                            .count
          items = User.select('id, name as text')
                      .where('name like ?', '%' + params[:q] + '%')
                      .page(params[:page]).per(25)
        else
          user = User.arel_table
          projects_user = ProjectsUser.arel_table
          join_on = user.create_on(user[:id].eq(projects_user[:user_id]))
          outer_join = user.create_join(projects_user, join_on, Arel::Nodes::OuterJoin)

          total_count = User.distinct
                            .joins(outer_join)
                            .where('name like ? ', '%' + params[:q] + '%')
                            .where('users.role <> 1 OR projects_users.project_id in (select pu.project_id from projects_users pu where pu.user_id = ?)', current_user.id)
                            .count
          items = User.select('users.id as id, users.name as text')
                      .distinct
                      .joins(outer_join)
                      .where('name like ? ', '%' + params[:q] + '%')
                      .where('users.role <> 1 OR projects_users.project_id in (select pu.project_id from projects_users pu where pu.user_id = ?)', current_user.id)
                      .page(params[:page]).per(25)
        end
        render json: {total_count: total_count, items: items} and return
      end
    end
  end

  def list_projects
    if params.has_key?(:q) && params.has_key?(:page)
      if current_user.system_admin? || current_user.gsas_trust_top_manager? || current_user.gsas_trust_manager? || current_user.gsas_trust_admin?
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

    def projects_user_params
      params.require(:projects_user).permit(:user_id, :role)
    end
end
