class CreatePerformanceLabel < ActiveRecord::Migration[5.2]
  def up
    create_table :scheme_criterion_performance_labels do |t|
      t.references :scheme_criterion, foreign_key: true, index: {name: 'index_perf_labels_to_scheme_criteria'}
      t.string :type, null: false
      t.string :label
      t.integer :display_weight, default: 0
      t.string :levels, default: [0, 1, 2, 3].to_yaml
      t.string :bands, default: ['A*', 'A', 'B', 'C', 'D', 'E', 'F', 'G'].to_yaml
    end

    create_table :scheme_mix_criterion_performance_labels do |t|
      t.references :scheme_mix_criterion, foreign_key: true, index: {name: 'index_perf_labels_to_scheme_mix_criteria'}
      t.references :scheme_criterion_performance_labels, foreign_key: true, index: {name: 'index_perf_labels_to_scheme_criterion_perf_labels'}
      t.string :type, null: false
      t.integer :level
      t.string :band
      t.decimal :epc
      t.decimal :wpc
      # unit = Mwh
      t.decimal :cooling
      t.decimal :lighting
      t.decimal :auxiliaries
      t.decimal :dhw
      t.decimal :others
      t.decimal :generation
      # unit = m3
      t.decimal :indoor_use
      t.decimal :irrigation
      t.decimal :cooling_tower
    end
  end

  def down
    drop_table :scheme_mix_criterion_performance_labels
    drop_table :scheme_criterion_performance_labels
  end
end
