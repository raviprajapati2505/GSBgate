class CreateRequirementCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :requirement_categories do |t|
      t.string :title, null: false
      t.integer :display_weight, null: false
      
      t.timestamps
    end
  end
end
