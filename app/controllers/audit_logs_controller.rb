class AuditLogsController < AuthenticatedController
  before_action :set_auditable, except: [ :index ]
  load_and_authorize_resource

  def index
    @page_title = 'Audit log'
    @default_values = {text: '', project_id: '', date_from: '', date_to: '', only_user_comments: false}
    @audit_logs = AuditLog.for_user_projects(current_user)

    # Get all users linked to one of the projects in the filter
    if current_user.system_admin? or current_user.gord_top_manager? or current_user.gord_manager?
      @users = User.all
    else
      user = User.arel_table
      projects_user = ProjectsUser.arel_table
      join_on = user.create_on(user[:id].eq(projects_user[:user_id]))
      outer_join = user.create_join(projects_user, join_on, Arel::Nodes::OuterJoin)
      @users = User.joins(outer_join).where('users.role <> 1 OR projects_users.project_id in (select pu.project_id from projects_users pu where pu.user_id = ?)', current_user.id).distinct
      # @users = User.includes(:projects_users).where('users.role <> 1 OR projects_users.project_id in (select pu.project_id from projects_users pu where pu.user_id = ?)', current_user.id).distinct
    end

    # Text filter
    if params[:text].present?
      @audit_logs = @audit_logs.where('(system_message ILIKE ?) OR (user_comment ILIKE ?)' , "%#{params[:text]}%", "%#{params[:text]}%")
      @default_values[:text] = params[:text]
    end

    # User filter
    if params[:user_id].present? and (params[:user_id].to_i > 0)
      @audit_logs = @audit_logs.where(user_id: params[:user_id].to_i)
      @default_values[:user_id] = params[:user_id]
    end

    # Project filter
    if params[:project_id].present? and (params[:project_id].to_i > 0)
      @audit_logs = @audit_logs.where(project_id: params[:project_id].to_i)
      @default_values[:project_id] = params[:project_id]
    end

    # Date from filter
    if params[:date_from].present?
      begin
        @audit_logs = @audit_logs.where('created_at >= ?', Date.strptime(params[:date_from], t('date.formats.short')))
        @default_values[:date_from] = params[:date_from]
      rescue ArgumentError
        flash[:alert] = 'The date from field contained invalid data.'
      end
    end

    # Date to filter
    if params[:date_to].present?
      begin
        @audit_logs = @audit_logs.where('created_at <= ?', Date.strptime(params[:date_to], t('date.formats.short')))
        @default_values[:date_to] = params[:date_to]
      rescue ArgumentError
        flash[:alert] = 'The date to field contained invalid data.'
      end
    end

    # Only show user comments filter
    if params[:only_user_comments].present?
      @audit_logs = @audit_logs.where.not(user_comment: nil)
      @default_values[:only_user_comments] = true
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

    unless @auditable.is_a?(AuditableRecord)
      raise CanCan::AccessDenied.new('Not Authorized to read audit logs for this model.', :read, AuditLog)
    end

    unless can?(:read, @auditable)
      raise CanCan::AccessDenied.new('Not Authorized to read audit logs for this model.', :read, AuditLog)
    end
  end
end
