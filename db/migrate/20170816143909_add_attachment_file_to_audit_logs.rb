class AddAttachmentFileToAuditLogs < ActiveRecord::Migration
  def change
    add_column :audit_logs, :attachment_file, :string
  end
end
