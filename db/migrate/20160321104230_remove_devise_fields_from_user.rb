class RemoveDeviseFieldsFromUser < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at
    remove_column :users, :remember_created_at
    remove_column :users, :current_sign_in_at
    remove_column :users, :current_sign_in_ip
    remove_column :users, :last_sign_in_ip
    remove_column :users, :last_notified_at
    remove_column :users, :confirmation_token
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_sent_at
    remove_column :users, :unconfirmed_email
    remove_column :users, :account_active
  end
end
