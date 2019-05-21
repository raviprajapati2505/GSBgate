class CreateSchemeCriterionIncentives < ActiveRecord::Migration[5.2]
  def up
    create_table :scheme_criterion_incentives do |t|
      t.references :scheme_criterion, foreign_key: true, index: { name: 'index_incentives_to_scheme_criteria' }
      t.decimal :incentive_weight, precision: 5, scale: 2, default: 0
      t.string :label
    end

    create_table :scheme_mix_criterion_incentives do |t|
      t.references :scheme_mix_criterion, foreign_key: true, index: { name: 'index_incentives_to_scheme_mix_criteria' }
      t.references :scheme_criterion_incentive, foreign_key: true, index: { name: 'index_incentives_to_scheme_criterion_incentives' }
      t.boolean :incentive_scored, default: false
    end
  end

  def down
    drop_table :scheme_mix_criterion_incentives
    drop_table :scheme_criterion_incentives
  end
end
