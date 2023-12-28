class AddNewStatusOldStatusToAuditLogs < ActiveRecord::Migration[4.2]
  def change
    add_column :audit_logs, :new_status, :integer
    add_column :audit_logs, :old_status, :integer
  end
end
