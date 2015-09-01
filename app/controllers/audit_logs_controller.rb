class AuditLogsController < AuthenticatedController
  before_action :set_auditable
  load_and_authorize_resource

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
