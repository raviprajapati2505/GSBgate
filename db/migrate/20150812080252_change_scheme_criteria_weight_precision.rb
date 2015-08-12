class ChangeSchemeCriteriaWeightPrecision < ActiveRecord::Migration
  def change
    change_column :scheme_criteria, :weight, :decimal, precision: 5, scale:2
  end
end
