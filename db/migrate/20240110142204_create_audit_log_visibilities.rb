class CreateAuditLogVisibilities < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_log_visibilities do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
