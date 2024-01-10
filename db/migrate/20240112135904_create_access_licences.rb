class CreateAccessLicences < ActiveRecord::Migration[7.0]
  def change
    create_table :access_licences do |t|
      t.references :user, foreign_key: true, index: true
      t.references :licence, foreign_key: true, index: true
      t.date :expiry_date
      t.string :licence_file
      t.index [:user_id, :licence_id], unique: true

      t.timestamps
    end
  end
end
