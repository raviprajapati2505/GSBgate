class ChangeExistingUserFields < ActiveRecord::Migration
  def change
    remove_index :users, :email
    change_column :users, :encrypted_password, :string, null: true
    change_column :users, :email, :string, null: false
  end
end
