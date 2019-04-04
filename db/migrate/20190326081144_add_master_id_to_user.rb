class AddMasterIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :employer_name, :string
  end
end
