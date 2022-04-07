class CreateAccessLicences < ActiveRecord::Migration[5.2]
  def change
    create_table :access_licences do |t|
      t.references :userable, polymorphic: true
      t.references :licence, index: true, foreign_key: true
      t.datetime :expiry_date

      t.timestamps
    end
  end
end
