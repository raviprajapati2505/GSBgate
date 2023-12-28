class AddDefaultValueForIncentiveWeight < ActiveRecord::Migration[4.2]
  def change
    change_column_default :scheme_criteria, :incentive_weight, 0
  end
end
