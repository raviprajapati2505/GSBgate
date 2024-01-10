class CreateSchemeMixCriteria < ActiveRecord::Migration[7.0]
  def change
    create_table :scheme_mix_criteria do |t|
      t.integer :targeted_score_a, precision: 3, scale: 1
      t.integer :submitted_score_a, precision: 3, scale: 1
      t.integer :achieved_score_a, precision: 3, scale: 1
      t.boolean :incentive_scored_a, default: false
      t.decimal :targeted_score_b, precision: 3, scale: 1
      t.decimal :submitted_score_b, precision: 3, scale: 1
      t.decimal :achieved_score_b, precision: 3, scale: 1
      t.boolean :incentive_scored_b, default: false
      t.boolean :epc_matches_energy_suite
      t.integer :status
      t.integer :review_count, default: 0
      t.date :due_date
      t.text :pcr_review_draft
      t.boolean :in_review, default: false
      t.boolean :screened, null: false, default: false
      t.references :scheme_mix, foreign_key: true, index: true
      t.references :scheme_criterion, foreign_key: true, index: true
      t.references :certifier, foreign_key: { to_table: :users }
      t.references :main_scheme_mix_criterion, foreign_key: { to_table: :scheme_mix_criteria }, index: true

      t.timestamps null: false
    end
  end
end
