class CreateLicences < ActiveRecord::Migration[5.2]
  def change
    create_table :licences do |t|
      t.string  :type
      t.string  :display_name
      t.string  :title
      t.string  :description
      t.integer :certificate_type
      t.integer :applicability, default: Licence.applicabilities[:both]
      t.text    :schemes, array: true, default: []

      t.timestamps
    end
  end
end
