class AddRoleToProjectAuthorizations < ActiveRecord::Migration[4.2]
  def change
    add_column :project_authorizations, :role, :integer
    remove_column :projects, :certifier_id
    remove_column :projects, :client_id
  end
end
