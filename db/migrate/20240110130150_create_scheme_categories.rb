class CreateSchemeCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :scheme_categories do |t|
      t.string :name
      t.string :code, limit: 4
      t.text :description
      t.text :impacts
      t.text :mitigate_impact
      t.integer :display_weight
      t.boolean :shared, default: false, null: false
      t.boolean :is_checklist, null: false, default: false
      t.references :scheme, foreign_key: true, index: true

      t.timestamps null: false
    end
    add_index :scheme_categories, [:code, :scheme_id], unique: true
  end
end
