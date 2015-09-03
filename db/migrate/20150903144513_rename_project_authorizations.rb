class RenameProjectAuthorizations < ActiveRecord::Migration
  def change
    rename_table :project_authorizations, :projects_users
  end
end
