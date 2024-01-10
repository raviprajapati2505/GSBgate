class CreateRequirements < ActiveRecord::Migration[7.0]
  def change
    create_table :requirements do |t|
      t.integer :calculator_id
      t.string :name
      t.integer :display_weight
      t.references :requirement_category, foreign_key: true

      t.timestamps null: false
    end
  end
end
