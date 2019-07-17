class AddCo2EmissionToSchemeMixCriterionPerformanceLabels < ActiveRecord::Migration[5.2]
  def up
    add_column :scheme_mix_criterion_performance_labels,:co2_emission, :decimal
  end

  def down
    remove_column :scheme_mix_criterion_performance_labels, :co2_emission
  end
end
