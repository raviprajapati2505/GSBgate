class AddMasterIdToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :employer_name, :string
  end
end
