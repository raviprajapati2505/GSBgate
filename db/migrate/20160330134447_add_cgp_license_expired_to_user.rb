class AddCgpLicenseExpiredToUser < ActiveRecord::Migration
  def change
    add_column :users, :cgp_license_expired, :boolean, null: false, default: false
  end
end
