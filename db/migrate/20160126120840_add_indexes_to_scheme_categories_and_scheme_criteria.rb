class AddIndexesToSchemeCategoriesAndSchemeCriteria < ActiveRecord::Migration
  def change
    add_index :scheme_categories, :code
    add_index :scheme_criteria, :number
  end
end
