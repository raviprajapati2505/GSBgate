class TasksController < AuthenticatedController
  load_and_authorize_resource

  def index
    @page_title = 'Tasks'
    @default_values = {project_id: nil}

    # Project filter
    if params[:project_id].present? and (params[:project_id].to_i > 0)
      @default_values[:project_id] = params[:project_id]
    end
    @tasks = OldTaskService.instance.generate_tasks(page: params[:page], user: current_user, project_id: @default_values[:project_id])
  end
end