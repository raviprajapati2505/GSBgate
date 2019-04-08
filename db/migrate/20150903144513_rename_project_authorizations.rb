class RenameProjectAuthorizations < ActiveRecord::Migration[4.2]
  def change
    rename_table :project_authorizations, :projects_users
  end
end
