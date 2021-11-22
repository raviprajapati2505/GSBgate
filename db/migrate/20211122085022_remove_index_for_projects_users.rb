class RemoveIndexForProjectsUsers < ActiveRecord::Migration[5.2]
  def change
    remove_index :projects_users, ["user_id", "project_id", "role"]
  end
end
