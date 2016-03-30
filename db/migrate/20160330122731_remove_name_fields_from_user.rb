class RemoveNameFieldsFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :name_prefix, :string
    remove_column :users, :first_name, :string
    remove_column :users, :middle_name, :string
    remove_column :users, :last_name, :string
    remove_column :users, :name_suffix, :string
  end
end
