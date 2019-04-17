class CreateDevelopmentTypes < ActiveRecord::Migration[4.2]

  def up
    create_table :development_types do |t|
      t.references :certificate, index: true, foreign_key: true
      t.string :name
      t.integer :display_weight, limit: 3
      t.boolean :mixable

      t.timestamps null: false
    end
    # add_index :development_types, [:certificate_id, :name], unique: true

    create_table :development_type_schemes do |t|
      t.references :development_type, index: true, foreign_key: true
      t.references :scheme, index: true, foreign_key: true
      t.timestamps null: false
    end
    # add_index :development_types, [:certificate_id, :name], unique: true

    add_column :schemes, :gsas_document, :string
    add_column :schemes, :certificate_type, :integer
    remove_foreign_key :schemes, :certificate
  end

  def down
    add_foreign_key :schemes, :certificate
    remove_column :schemes, :certificate_type
    remove_column :schemes, :gsas_document
    drop_table :development_type_schemes
    drop_table :development_types
  end
end
