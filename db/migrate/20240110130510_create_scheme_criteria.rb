class CreateSchemeCriteria < ActiveRecord::Migration[7.0]
  def change
    create_table :scheme_criteria do |t|
      t.references :scheme_category, foreign_key: true, index: true
      t.decimal :weight_a, precision: 5, scale: 2
      t.string :name
      t.integer :number, index: true
      t.string :scores_a
      t.string :scores_b
      t.string :label_a
      t.string :label_b
      t.decimal :incentive_weight_minus_1_a, precision: 5, scale: 2, default: 0
      t.decimal :incentive_weight_0_a, precision: 5, scale: 2, default: 0.0
      t.decimal :incentive_weight_1_a, precision: 5, scale: 2, default: 0.0
      t.decimal :incentive_weight_2_a, precision: 5, scale: 2, default: 0.0
      t.decimal :incentive_weight_3_a, precision: 5, scale: 2, default: 0.0
      t.integer :minimum_score_a, null: false, precision: 3, scale: 1
      t.integer :maximum_score_a, null: false, precision: 3, scale: 1
      t.integer :minimum_valid_score_a, null: false, precision: 3, scale: 1
      t.boolean :calculate_incentive_a, default: true
      t.boolean :calculate_incentive_b, default: false
      t.boolean :assign_incentive_manually_a, default: false
      t.boolean :assign_incentive_manually_b, default: false
      t.boolean :shared, default: true, null: false
      t.boolean :is_checklist, default: false, null: false
      t.decimal :weight_b, precision: 5, scale: 2, default: 0.0
      t.decimal :minimum_score_b, precision: 4, scale: 1
      t.decimal :maximum_score_b, precision: 4, scale: 1
      t.decimal :minimum_valid_score_b, precision: 4, scale: 1
      t.decimal :incentive_weight_minus_1_b, precision: 5, scale: 2, default: 0.0
      t.decimal :incentive_weight_0_b, precision: 5, scale: 2, default: 0.0
      t.decimal :incentive_weight_1_b, precision: 5, scale: 2, default: 0.0
      t.decimal :incentive_weight_2_b, precision: 5, scale: 2, default: 0.0
      t.decimal :incentive_weight_3_b, precision: 5, scale: 2, default: 0.0

      t.timestamps null: false
    end

    add_index :scheme_criteria, [:scheme_category_id, :number], unique: true
    add_index :scheme_criteria, [:scheme_category_id, :name], unique: true
  end
end
