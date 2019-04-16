class ClearUnusedAuditLogStatuses < ActiveRecord::Migration[4.2]
  def change
    AuditLog.where(auditable_type: 'SchemeMixCriterion').update_all(new_status: nil, old_status: nil)
    AuditLog.where(auditable_type: 'RequirementDatum').update_all(new_status: nil, old_status: nil)
    AuditLog.where(auditable_type: 'SchemeMixCriteriaDocument').update_all(new_status: nil, old_status: nil)
  end
end
