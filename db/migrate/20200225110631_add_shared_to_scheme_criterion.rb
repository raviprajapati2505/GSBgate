class AddSharedToSchemeCriterion < ActiveRecord::Migration[5.2]
  def change
    add_column :scheme_criteria, :shared, :boolean, default: true, null: false
  end
end
