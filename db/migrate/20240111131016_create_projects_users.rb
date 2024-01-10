class CreateProjectsUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :projects_users do |t|
      t.references :user, foreign_key: true, index: true
      t.belongs_to :project, foreign_key: true, index: true
      t.integer :role
      t.integer :certification_team_type, default: 0

      t.timestamps null: false
    end
  end
end
