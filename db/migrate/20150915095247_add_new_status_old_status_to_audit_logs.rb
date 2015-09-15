class AddNewStatusOldStatusToAuditLogs < ActiveRecord::Migration
  def change
    add_column :audit_logs, :new_status, :integer
    add_column :audit_logs, :old_status, :integer
  end
end
