class AddLicenceFileAccessLicence < ActiveRecord::Migration[5.2]
  def change
    add_column :access_licences, :licence_file, :string
  end
end
