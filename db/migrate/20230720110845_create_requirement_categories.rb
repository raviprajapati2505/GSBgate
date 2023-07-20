class CreateRequirementCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :requirement_categories do |t|
      t.string :title, null: false
      t.integer :display_weight, null: false
      
      t.timestamps
    end
    
    # Add reference of requirement_categories to requirement
    add_reference :requirements, :requirement_category
  end
end
