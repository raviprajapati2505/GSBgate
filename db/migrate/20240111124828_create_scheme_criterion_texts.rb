class CreateSchemeCriterionTexts < ActiveRecord::Migration[7.0]
  def change
    create_table :scheme_criterion_texts do |t|
      t.string :name
      t.text :html_text
      t.integer :display_weight
      t.boolean :visible
      t.references :scheme_criterion, foreign_key: true, index: true

      t.timestamps null: false
    end

    add_index :scheme_criterion_texts, [:name, :scheme_criterion_id], unique: true
  end
end
