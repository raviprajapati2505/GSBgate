class AddIncentiveWeightToCriterion < ActiveRecord::Migration[4.2]
  def change
    add_column :scheme_criteria, :incentive_weight, :decimal, precision: 5, scale:2
  end
end
