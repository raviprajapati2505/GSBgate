class AddCertificationPathIdToAuditLog < ActiveRecord::Migration[4.2]
  def change
    add_column :audit_logs, :certification_path_id, :integer
  end
end
