class CreateAccessLicences < ActiveRecord::Migration[5.2]
  def change
    create_table :access_licences do |t|
      t.references :user, index: true, foreign_key: true
      t.references :licence, index: true, foreign_key: true
      t.date :expiry_date
      t.index [:user_id, :licence_id]

      t.timestamps
    end
  end
end
