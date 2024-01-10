class CreateSchemeCriterionPerformanceLabels < ActiveRecord::Migration[7.0]
  def change
    create_table :scheme_criterion_performance_labels do |t|
      t.references :scheme_criterion, foreign_key: true, index: {name: 'index_perf_labels_to_scheme_criteria'}
      t.string :type, null: false
      t.string :label
      t.integer :display_weight, default: 0
      t.string :levels, default: [0, 1, 2, 3].to_yaml
      t.string :bands, default: ['A*', 'A', 'B', 'C', 'D', 'E', 'F', 'G'].to_yaml

      t.timestamps null: false
    end
  end
end
