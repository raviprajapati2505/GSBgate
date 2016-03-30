class AddVisibilityToAuditLogs < ActiveRecord::Migration
  def change
    create_table :audit_log_visibilities do |t|
      t.string :name, null: false
    end
    add_reference :audit_logs, :audit_log_visibility, references: :audit_log_visibilities, index: true
    add_foreign_key :audit_logs, :audit_log_visibilities
  end
end
