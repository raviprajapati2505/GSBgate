class AuditLogsController < AuthenticatedController
  before_action :set_auditable, only: [:auditable_index]
  load_and_authorize_resource

  def auditable_index
    @audit_logs = AuditLog.for_auditable(@auditable).paginate page: params[:page], per_page: 8
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
