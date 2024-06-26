class CreateSchemes < ActiveRecord::Migration[7.0]
  def change
    create_table :schemes do |t|
      t.string :name
      t.string :gsb_version
      t.string :gsb_document
      t.string :certificate_type
      t.boolean :renovation, default: false
      t.integer :certification_type

      t.timestamps null: false
    end

    add_index :schemes, [:name, :gsb_version, :renovation], unique: true, name: 'index_schemes_on_name_gsbversion_certificateid_renovation'
  end
end
