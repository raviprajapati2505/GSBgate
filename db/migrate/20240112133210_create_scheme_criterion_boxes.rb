class CreateSchemeCriterionBoxes < ActiveRecord::Migration[7.0]
  def change
    create_table :scheme_criterion_boxes do |t|
      t.references :scheme_criterion, foreign_key: true
      t.string :label
      t.integer :display_weight
      t.boolean :is_checked

      t.timestamps
    end
  end
end
