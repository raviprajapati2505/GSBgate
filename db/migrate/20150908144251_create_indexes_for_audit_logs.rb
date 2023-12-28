class CreateIndexesForAuditLogs < ActiveRecord::Migration[4.2]
  def change
    add_index :audit_logs, :system_message
    add_index :audit_logs, :user_comment
  end
end
