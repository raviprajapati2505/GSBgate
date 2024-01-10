class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.integer :task_description_id, null: false
      t.integer :application_role
      t.integer :project_role
      t.references :user, foreign_key: true, index: true
      t.references :project, foreign_key: true, index: true
      t.references :certification_path, foreign_key: true, index: true
      t.references :taskable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
