class DeleteRoles < ActiveRecord::Migration[4.2]
  def change
    remove_reference :users, :role
    drop_table :roles
    add_column :users, :role, :integer
  end
end
