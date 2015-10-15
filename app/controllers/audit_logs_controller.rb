class AuditLogsController < AuthenticatedController
  before_action :set_auditable, except: [ :index ]
  load_and_authorize_resource

  def index
    @page_title = 'Audit log'
    if current_user.system_admin? or current_user.gord_manager? or current_user.gord_top_manager?
      @projects = Project.all
    else
      @projects = current_user.projects
    end

    session[:audit_text] ||= ''
    session[:audit_user_id] ||= ''
    session[:audit_project_id] ||= ''
    session[:audit_certification_path_id] ||= ''
    session[:audit_date_from] ||= ''
    session[:audit_time_from] ||= '0:00'
    session[:audit_date_to] ||= ''
    session[:audit_time_to] ||= '0:00'
    session[:audit_only_comments] ||= false
    @audit_logs = AuditLog.for_user_projects(current_user)
    @certification_paths_optionlist = []

    # Text filter
    if params[:text].present?
      @audit_logs = @audit_logs.where('(system_message ILIKE ?) OR (user_comment ILIKE ?)' , "%#{params[:text]}%", "%#{params[:text]}%")
      session[:audit_text] = params[:text]
    end

    # User filter
    if params[:user_id].present? and (params[:user_id].to_i > 0)
      @audit_logs = @audit_logs.where(user_id: params[:user_id].to_i)
      session[:audit_user_id] = params[:user_id]
    end

    # Project filter
    if params[:project_id].present? and (params[:project_id].to_i > 0)
      @audit_logs = @audit_logs.where(project_id: params[:project_id].to_i)
      session[:audit_project_id] = params[:project_id]
      @certification_paths_optionlist = Project.find(params[:project_id].to_i).certification_paths_optionlist
    end

    # Certification path filter
    if params[:certification_path_id].present? and (params[:certification_path_id].to_i > 0)
      @audit_logs = @audit_logs.where(certification_path_id: params[:certification_path_id].to_i)
      session[:audit_certification_path_id] = params[:certification_path_id]
    end

    # Date from filter
    if params[:date_from].present?
      begin
        @audit_logs = @audit_logs.where('created_at >= ?', DateTime.strptime(params[:date_from] + ' ' + params[:time_from] + ':00', t('time.formats.filter')))
        session[:audit_date_from] = params[:date_from]
        session[:audit_time_from] = params[:time_from]
      rescue ArgumentError
        flash[:alert] = 'The date/time from fields contained invalid data.'
      end
    end

    # Date to filter
    if params[:date_to].present?
      begin
        @audit_logs = @audit_logs.where('created_at <= ?', DateTime.strptime(params[:date_to] + ' ' + params[:time_to] + ':59', t('time.formats.filter')))
        session[:audit_date_to] = params[:date_to]
        session[:audit_time_to] = params[:time_to]
      rescue ArgumentError
        flash[:alert] = 'The date/time to fields contained invalid data.'
      end
    end

    # Only show user comments filter
    if params[:only_user_comments].present?
      @audit_logs = @audit_logs.where.not(user_comment: nil)
      session[:audit_only_comments] = true
    end

    @audit_logs = @audit_logs.paginate page: params[:page], per_page: 12
  end

  def auditable_index
    @audit_logs = AuditLog.for_auditable(@auditable).paginate page: params[:page], per_page: 6
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

    unless auditable_class.included_modules.include?(Auditable)
      raise CanCan::AccessDenied.new('Not Authorized to read audit logs for this model.', :read, AuditLog)
    end

    unless can?(:read, @auditable)
      raise CanCan::AccessDenied.new('Not Authorized to read audit logs for this model.', :read, AuditLog)
    end
  end
end
