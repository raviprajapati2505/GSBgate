class AddIncentiveSchemeMixCriterion < ActiveRecord::Migration
  def change
    add_column :scheme_mix_criteria, :incentive_scored, :boolean, default: false
    add_column :scheme_criteria, :incentive_weight, :decimal, precision: 3, scale: 1, default: 0
  end
end
