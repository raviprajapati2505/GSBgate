class AddOtpFieldToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :otp, :integer
  end
end
