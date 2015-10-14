class TasksController < AuthenticatedController
  load_and_authorize_resource

  def index
    @page_title = 'Tasks'

    session[:project_id] = nil

    # Project filter
    if params[:project_id].present? and (params[:project_id].to_i > 0)
      session[:project_id] = params[:project_id]
    end

    @tasks = TaskService::get_tasks(page: params[:page], per_page: 25, user: current_user, project_id: session[:project_id])
  end
end