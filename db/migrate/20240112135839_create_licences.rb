class CreateLicences < ActiveRecord::Migration[7.0]
  def change
    create_table :licences do |t|
      t.string  :licence_type
      t.integer :display_weight, default: 0
      t.string  :display_name
      t.string  :title
      t.string  :description
      t.integer :certificate_type
      t.integer :time_period             # In months
      t.integer :applicability, default: Licence.applicabilities[:both]
      t.text    :schemes, array: true, default: []

      t.timestamps
    end
  end
end
