class AddUniqueIndexToProjectUsers < ActiveRecord::Migration[4.2]
  def change
    add_index :projects_users, [:user_id, :project_id, :role], unique: true
  end
end
