class AddCodeToSchemeCriterion < ActiveRecord::Migration[4.2]
  def change
    add_column :scheme_criteria, :code, :string
    remove_column :criteria, :code
  end
end
