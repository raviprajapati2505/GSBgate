class CombineAccessRights < ActiveRecord::Migration[4.2]
  def change
    add_column :project_authorizations, :permission, :integer
    remove_column :project_authorizations, :project_manager
    remove_column :project_authorizations, :write_access
  end
end
