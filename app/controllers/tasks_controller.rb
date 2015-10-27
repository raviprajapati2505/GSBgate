class TasksController < AuthenticatedController
  load_and_authorize_resource

  def index
    @page_title = 'Tasks'
    if current_user.system_admin? || current_user.gord_manager? || current_user.gord_top_manager?
      @projects = Project.all
    else
      @projects = current_user.projects
    end

    if params[:reset].present?
      session[:task] = {'project_id' => nil}
    else
      if params[:button].present?
        session[:task] = {'project_id' => nil}
      else
        session[:task] ||= {'project_id' => nil}
      end

      # Project filter
      if params[:project_id].present? && (params[:project_id].to_i > 0)
        session[:task]['project_id'] = params[:project_id]
      end
    end

    @tasks = TaskService::get_tasks(page: params[:page], per_page: 25, user: current_user, project_id: session[:task]['project_id'])
  end

  def count
    if params.has_key?(:user_id)
      user = User.find_by(id: params[:user_id].to_i)
      if params.has_key?(:project_id)
        project_id = params[:project_id].to_i
      else
        project_id = nil
      end
      render json: TaskService::count_tasks(user: user, project_id: project_id)
    end
  end
end