class AddCodeToSchemeCriterion < ActiveRecord::Migration
  def change
    add_column :scheme_criteria, :code, :string
    remove_column :criteria, :code
  end
end
