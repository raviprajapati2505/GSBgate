class RemoveDefaultValueFromProjectOwner < ActiveRecord::Migration
  def change
    remove_column :projects, :owner
    add_column :projects, :owner, :string, null: false, default: ''
  end
end
