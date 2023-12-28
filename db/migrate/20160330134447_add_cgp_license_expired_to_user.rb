class AddCgpLicenseExpiredToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :cgp_license_expired, :boolean, null: false, default: false
  end
end
