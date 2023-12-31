class AddNameFieldsToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :name_prefix, :string
    add_column :users, :first_name, :string
    add_column :users, :middle_name, :string
    add_column :users, :last_name, :string
    add_column :users, :name_suffix, :string
  end
end
