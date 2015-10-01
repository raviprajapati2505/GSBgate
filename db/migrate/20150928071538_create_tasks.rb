class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :task_type, null: false
      t.integer :task_description_id, null: false
      t.integer :application_role
      t.integer :project_role
      t.references :user, index: true, foreign_key: true
      t.references :project, index: true, foreign_key: true
      t.references :certification_path, index: true, foreign_key: true
      t.references :scheme_mix_criterion, index: true, foreign_key: true
      t.references :requirement_datum, index: true, foreign_key: true
      t.references :scheme_mix_criteria_document, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
