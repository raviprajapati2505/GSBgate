class AddAttachmentFileToAuditLogs < ActiveRecord::Migration[4.2]
  def change
    add_column :audit_logs, :attachment_file, :string
  end
end
