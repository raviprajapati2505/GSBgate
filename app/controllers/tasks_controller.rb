class TasksController < AuthenticatedController
  load_and_authorize_resource

  def index
    @page_title = 'Tasks'
    if current_user.system_admin? or current_user.gord_manager? or current_user.gord_top_manager?
      @projects = Project.all
    else
      @projects = current_user.projects
    end

    session[:task_project_id] ||= nil

    # Project filter
    if params[:project_id].present? and (params[:project_id].to_i > 0)
      session[:task_project_id] = params[:project_id]
    end

    @tasks = TaskService::get_tasks(page: params[:page], per_page: 25, user: current_user, project_id: session[:task_project_id])
  end
end