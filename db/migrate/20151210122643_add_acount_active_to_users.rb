class AddAcountActiveToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :account_active, :boolean, default: true, null: false
    User.update_all({:account_active => true})
  end
end
