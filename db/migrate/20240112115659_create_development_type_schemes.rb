class CreateDevelopmentTypeSchemes < ActiveRecord::Migration[7.0]
  def change
    create_table :development_type_schemes do |t|
      t.references :development_type, foreign_key: true, index: true
      t.references :scheme, foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
