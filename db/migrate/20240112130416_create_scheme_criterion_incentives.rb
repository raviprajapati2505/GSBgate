class CreateSchemeCriterionIncentives < ActiveRecord::Migration[7.0]
  def change
    create_table :scheme_criterion_incentives do |t|
      t.decimal :incentive_weight, precision: 5, scale: 2, default: 0
      t.string :label
      t.integer :display_weight
      t.references :scheme_criterion, foreign_key: true, index: { name: 'index_incentives_to_scheme_criteria' }

      t.timestamps null: false
    end
  end
end
