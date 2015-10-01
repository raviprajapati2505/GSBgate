class AddIncentiveWeightToCriterion < ActiveRecord::Migration
  def change
    add_column :scheme_criteria, :incentive_weight, :decimal, precision: 5, scale:2
  end
end
