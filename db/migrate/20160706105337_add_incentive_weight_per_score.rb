class AddIncentiveWeightPerScore < ActiveRecord::Migration
  def up
    add_column :scheme_criteria, :incentive_weight_minus_1, :decimal, precision: 5, scale:2, default: 0
    add_column :scheme_criteria, :incentive_weight_0, :decimal, precision: 5, scale:2, default: 0
    add_column :scheme_criteria, :incentive_weight_1, :decimal, precision: 5, scale:2, default: 0
    add_column :scheme_criteria, :incentive_weight_2, :decimal, precision: 5, scale:2, default: 0
    add_column :scheme_criteria, :incentive_weight_3, :decimal, precision: 5, scale:2, default: 0
    SchemeCriterion.update_all('incentive_weight_minus_1 = 0')
    SchemeCriterion.update_all('incentive_weight_0 = 0')
    SchemeCriterion.update_all('incentive_weight_1 = incentive_weight')
    SchemeCriterion.update_all('incentive_weight_2 = incentive_weight')
    SchemeCriterion.update_all('incentive_weight_3 = incentive_weight')
    remove_column :scheme_criteria, :incentive_weight
  end

  def down
    add_column :scheme_criteria, :incentive_weight, :decimal, precision: 5, scale:2, default: 0
    SchemeCriterion.update_all('incentive_weight = incentive_weight_3')
    remove_column :scheme_criteria, :incentive_weight_minus_1
    remove_column :scheme_criteria, :incentive_weight_0
    remove_column :scheme_criteria, :incentive_weight_1
    remove_column :scheme_criteria, :incentive_weight_2
    remove_column :scheme_criteria, :incentive_weight_3
  end
end
