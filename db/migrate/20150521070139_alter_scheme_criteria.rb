class AlterSchemeCriteria < ActiveRecord::Migration
  def change
    remove_column :scheme_criteria, :weight
    add_column :scheme_criteria, :weight, :decimal, precision: 4, scale:2
  end
end
