class CreateDevelopmentTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :development_types do |t|
      t.references :certificate, foreign_key: true, index: true
      t.string :name
      t.integer :display_weight, limit: 3
      t.boolean :mixable

      t.timestamps null: false
    end
  end
end
