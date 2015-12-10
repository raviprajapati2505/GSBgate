class AddAcountActiveToUsers < ActiveRecord::Migration
  def change
    add_column :users, :account_active, :boolean, default: true, null: false
    User.update_all({:account_active => true})
  end
end
