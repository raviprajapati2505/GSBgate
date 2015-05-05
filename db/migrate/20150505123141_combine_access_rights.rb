class CombineAccessRights < ActiveRecord::Migration
  def change
    add_column :project_authorizations, :permission, :integer
    remove_column :project_authorizations, :project_manager
    remove_column :project_authorizations, :write_access
  end
end
