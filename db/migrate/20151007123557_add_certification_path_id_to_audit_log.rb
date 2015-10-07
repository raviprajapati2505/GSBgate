class AddCertificationPathIdToAuditLog < ActiveRecord::Migration
  def change
    add_column :audit_logs, :certification_path_id, :integer
  end
end
