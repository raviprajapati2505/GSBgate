class AddIndexesToSchemeCategoriesAndSchemeCriteria < ActiveRecord::Migration[4.2]
  def change
    add_index :scheme_categories, :code
    add_index :scheme_criteria, :number
  end
end
