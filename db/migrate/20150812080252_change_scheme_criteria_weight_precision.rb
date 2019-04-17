class ChangeSchemeCriteriaWeightPrecision < ActiveRecord::Migration[4.2]
  def change
    change_column :scheme_criteria, :weight, :decimal, precision: 5, scale:2
  end
end
