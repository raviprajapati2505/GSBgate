class DeleteRoles < ActiveRecord::Migration
  def change
    remove_reference :users, :role
    drop_table :roles
    add_column :users, :role, :integer
  end
end
