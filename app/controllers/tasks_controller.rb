class TasksController < AuthenticatedController
  load_and_authorize_resource except: [:confirm_destroy]

  def index
    @page_title = 'Tasks'
    if current_user.is_system_admin? || current_user.is_gsb_manager? || current_user.is_gsb_top_manager? || current_user.is_gsb_admin?
      @projects = Project.all
    else
      @projects = current_user.projects
    end

    if params[:reset].present?
      session[:task] = {'project_id' => nil, 'certification_path_id' => nil}
    else
      if params[:button].present?
        session[:task] = {'project_id' => nil, 'certification_path_id' => nil}
      else
        session[:task] ||= {'project_id' => nil, 'certification_path_id' => nil}
      end

      # Project filter
      if params[:project_id].present? && (params[:project_id].to_i > 0)
        session[:task]['project_id'] = params[:project_id]
      end

      # Certificate filter
      if params[:certification_path_id].present? && (params[:certification_path_id].to_i > 0)
        session[:task]['certification_path_id'] = params[:certification_path_id]
      end
    end

    # TODO: investigate if refactor to use load_and_authorize_resource is possible ?
    @tasks = TaskService::get_tasks(page: params[:page], per_page: 25, user: current_user,
                                    project_id: session[:task]['project_id'],
                                    certification_path_id: session[:task]['certification_path_id'])
  end

  def confirm_destroy
    Task.find(params[:task_id]).destroy
    redirect_to tasks_path, notice: "Task removed successfully" and return
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