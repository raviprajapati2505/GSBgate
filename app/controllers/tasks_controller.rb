class TasksController < AuthenticatedController
  load_and_authorize_resource

  def index
    @page_title = 'Tasks'
    @default_values = {user_id: '', project_id: nil}

    # User filter
    if params[:user_id].present? and (params[:user_id].to_i > 0)
      user = User.find(params[:user_id].to_i)
      @default_values[:user_id] = params[:user_id]
    end

    # Project filter
    if params[:project_id].present? and (params[:project_id].to_i > 0)
      @default_values[:project_id] = params[:project_id]
    end

    @tasks = TaskService::get_tasks(page: params[:page], user: (user.present? ? user : nil), project_id: @default_values[:project_id])
  end
end