class AddRoleToProjectAuthorizations < ActiveRecord::Migration
  def change
    add_column :project_authorizations, :role, :integer
    remove_column :projects, :certifier_id
    remove_column :projects, :client_id
  end
end
