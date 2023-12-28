class AddDisplayWeightToSchemeCriterionIncentives < ActiveRecord::Migration[5.2]
  def change
    add_column :scheme_criterion_incentives, :display_weight, :integer
  end
end
