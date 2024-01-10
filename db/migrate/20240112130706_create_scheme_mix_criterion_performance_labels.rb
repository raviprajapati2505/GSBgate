class CreateSchemeMixCriterionPerformanceLabels < ActiveRecord::Migration[7.0]
  def change
    create_table :scheme_mix_criterion_performance_labels do |t|
      t.references :scheme_mix_criterion, foreign_key: true, index: { name: 'index_perf_labels_to_scheme_mix_criteria' }
      t.references :scheme_criterion_performance_labels, foreign_key: true, index: { name: 'index_perf_labels_to_scheme_criterion_perf_labels' }
      t.string :type, null: false
      t.integer :level
      t.string :band
      t.decimal :epc
      t.decimal :wpc
      t.decimal :cooling
      t.decimal :lighting
      t.decimal :auxiliaries
      t.decimal :dhw
      t.decimal :others
      t.decimal :generation
      t.decimal :indoor_use
      t.decimal :irrigation
      t.decimal :cooling_tower
      t.decimal :co2_emission

      t.timestamps
    end
  end
end
