class TasksController < AuthenticatedController
  load_and_authorize_resource

  def index
    @page_title = 'Tasks'
    if current_user.system_admin? || current_user.gord_manager? || current_user.gord_top_manager? || current_user.gord_admin?
      @projects = Project.all
    else
      @projects = current_user.projects
    end

    if params[:reset].present?
      session[:task] = {'project_id' => nil, 'certification_path_id' => nil, 'scheme_mix_criterion_id' => nil}
    else
      if params[:button].present?
        session[:task] = {'project_id' => nil, 'certification_path_id' => nil, 'scheme_mix_criterion_id' => nil}
      else
        session[:task] ||= {'project_id' => nil, 'certification_path_id' => nil, 'scheme_mix_criterion_id' => nil}
      end

      # Project filter
      if params[:project_id].present? && (params[:project_id].to_i > 0)
        session[:task]['project_id'] = params[:project_id]
      end

      # Certificate filter
      if params[:certification_path_id].present? && (params[:certification_path_id].to_i > 0)
        session[:task]['certification_path_id'] = params[:certification_path_id]
      end

      # Criterion filter
      if params[:scheme_mix_criterion_id].present? && (params[:scheme_mix_criterion_id].to_i > 0)
        session[:task]['scheme_mix_criterion_id'] = params[:scheme_mix_criterion_id]
      end
    end

    if session[:task]['scheme_mix_criterion_id'].present?
      scheme_mix_criterion_id = session[:task]['scheme_mix_criterion_id'].split(';')[1].to_i
    else
      scheme_mix_criterion_id = nil
    end

    # TODO: investigate if refactor to use load_and_authorize_resource is possible ?
    @tasks = TaskService::get_tasks(page: params[:page], per_page: 25, user: current_user,
                                    project_id: session[:task]['project_id'],
                                    certification_path_id: session[:task]['certification_path_id'],
                                    scheme_mix_criterion_id: scheme_mix_criterion_id)
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