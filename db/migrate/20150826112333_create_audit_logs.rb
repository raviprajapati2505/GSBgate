class CreateAuditLogs < ActiveRecord::Migration[4.2]
  def change
    create_table :audit_logs do |t|
      t.text :system_message
      t.text :user_comment
      t.references :auditable, polymorphic: true, index: true
      t.references :project, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    drop_table :notifications
    drop_table :scheme_mix_criterion_logs
    drop_table :scheme_mix_criteria_document_comments
  end
end
