class CreateAuditLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_logs do |t|
      t.text :system_message
      t.text :user_comment
      t.integer :new_status
      t.integer :old_status
      t.integer :certification_path_id
      t.string :attachment_file
      t.references :auditable, polymorphic: true, index: true
      t.references :project, foreign_key: true, index: true
      t.references :user, foreign_key: true, index: true
      t.references :audit_log_visibility, foreign_key: true, index: true

      t.timestamps null: false
    end

    add_index :audit_logs, :system_message
    add_index :audit_logs, :user_comment
  end
end
