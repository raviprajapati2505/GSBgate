class AuditLogsController < AuthenticatedController
  before_action :set_auditable, except: [ :index ]
  load_and_authorize_resource

  def index
    @page_title = 'Audit log'
    @projects = Project.accessible_by(current_ability)

    # TODO: investigate if refactor to use load_and_authorize_resource is possible ?
    @audit_logs = AuditLog.for_user_projects(current_user).includes(:user, :project)
    @certification_paths_optionlist = []

    if params[:reset].present?
      session[:audit] = {'text' => nil, 'user_id' => nil, 'project_id' => nil, 'certification_path_id' => nil, 'date_from' => '', 'time_from' => '0:00', 'date_to' => '', 'time_to' => '0:00', 'only_comments' => false}
    else

      if params[:button].present?
        session[:audit] = {'text' => nil, 'user_id' => nil, 'project_id' => nil, 'certification_path_id' => nil, 'date_from' => '', 'time_from' => '0:00', 'date_to' => '', 'time_to' => '0:00', 'only_comments' => false}
      else
        session[:audit] ||= {'text' => nil, 'user_id' => nil, 'project_id' => nil, 'certification_path_id' => nil, 'date_from' => '', 'time_from' => '0:00', 'date_to' => '', 'time_to' => '0:00', 'only_comments' => false}
      end

      # Text filter
      if params[:text].present?
        session[:audit]['text'] = params[:text]
      end
      if session[:audit]['text'].present?
        @audit_logs = @audit_logs.where('(system_message ILIKE ?) OR (user_comment ILIKE ?)' , "%#{session[:audit]['text']}%", "%#{session[:audit]['text']}%")
      end

      # User filter
      if params[:user_id].present? && (params[:user_id].to_i > 0)
        session[:audit]['user_id'] = params[:user_id]
      end
      if session[:audit]['user_id'].present?
        @audit_logs = @audit_logs.where(user_id: session[:audit]['user_id'].to_i)
      end

      # Project filter
      if params[:project_id].present? && (params[:project_id].to_i > 0)
        session[:audit]['project_id'] = params[:project_id]
      end
      if session[:audit]['project_id'].present?
        @audit_logs = @audit_logs.where(project_id: session[:audit]['project_id'].to_i)
      end

      # Certification path filter
      if params[:certification_path_id].present? && (params[:certification_path_id].to_i > 0)
        session[:audit]['certification_path_id'] = params[:certification_path_id]
      end
      if session[:audit]['certification_path_id'].present?
        @audit_logs = @audit_logs.where(certification_path_id: session[:audit]['certification_path_id'].to_i)
      end

      # Date from filter
      if params[:date_from].present?
        session[:audit]['date_from'] = params[:date_from]
        session[:audit]['tim_from'] = params[:time_from]
      end
      if session[:audit]['date_from'].present?
        begin
          @audit_logs = @audit_logs.where('created_at >= ?', DateTime.strptime(session[:audit]['date_from'] + ' ' + session[:audit]['tim_from'] + ':00', t('time.formats.filter')))
        rescue ArgumentError
          flash[:alert] = 'The date/time from fields contained invalid data.'
        end
      end

      # Date to filter
      if params[:date_to].present?
        session[:audit]['date_to'] = params[:date_to]
        session[:audit]['time_to'] = params[:time_to]
      end
      if session[:audit]['date_to'].present?
        begin
          @audit_logs = @audit_logs.where('created_at <= ?', DateTime.strptime(session[:audit]['date_to'] + ' ' + session[:audit]['time_to'] + ':59', t('time.formats.filter')))
        rescue ArgumentError
          flash[:alert] = 'The date/time to fields contained invalid data.'
        end
      end

      # Only show user comments filter
      if params[:only_user_comments].present?
        session[:audit]['only_comments'] = true
      end
      if session[:audit]['only_comments'] == true
        @audit_logs = @audit_logs.where.not(user_comment: nil)
      end
    end

    @audit_logs = @audit_logs.paginate page: params[:page], per_page: 12
  end

  def auditable_index
    @audit_logs = AuditLog.for_auditable(@auditable).paginate page: params[:page], per_page: 6
    @only_user_comments = false
  end

  def auditable_index_comments
    @audit_logs = AuditLog.for_auditable(@auditable).with_user_comment.paginate page: params[:page], per_page: 6
    @only_user_comments = true
  end

  def auditable_create
    if params[:audit_log][:user_comment].present?
      @auditable.audit_log_user_comment = params[:audit_log][:user_comment]
      @auditable.touch
      redirect_to :back, notice: 'Your comment was successfully added to the audit log.'
    else
      redirect_to :back, alert: 'Please fill out the comment field.'
    end
  end

  private
  def set_auditable
    auditable_class = Object.const_get params[:auditable_type]
    @auditable = auditable_class.find(params[:auditable_id])

    #todo: check this with authorize!(auditable_index)
    unless auditable_class.included_modules.include?(Auditable)
      raise CanCan::AccessDenied.new('Not Authorized to read audit logs for this model.', :read, AuditLog)
    end

    unless can?(:read, @auditable)
      raise CanCan::AccessDenied.new('Not Authorized to read audit logs for this model.', :read, AuditLog)
    end
  end
end
