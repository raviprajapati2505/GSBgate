class AddIsChecklistInSchemeCategoriesAndSchemeCriteria < ActiveRecord::Migration[5.2]
  def change
    add_column :scheme_categories, :is_checklist, :boolean, null: false, default: false
    add_column :scheme_criteria, :is_checklist, :boolean, null: false, default: false
  end
end
