class CreateUserTasks < ActiveRecord::Migration[4.2]
  def change
    create_table :user_tasks do |t|
      t.string :type, null: false
      t.integer :flow_index, null: false
      t.integer :role
      t.integer :project_role
      t.references :user, index:true, foreign_key: true
      t.references :project, index:true, foreign_key: true
      t.references :certification_path, index:true, foreign_key:true
      t.references :scheme_mix_criterion, index:true, foreign_key:true
      t.references :requirement_datum, index:true, foreign_key:true
      t.references :scheme_mix_criteria_document, index:true, foreign_key:true

      t.timestamps null: false
    end
  end
end
