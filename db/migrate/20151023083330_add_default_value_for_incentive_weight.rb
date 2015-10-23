class AddDefaultValueForIncentiveWeight < ActiveRecord::Migration
  def change
    change_column_default :scheme_criteria, :incentive_weight, 0
  end
end
