class CreateSchemeMixCriterionIncentives < ActiveRecord::Migration[7.0]
  def change
    create_table :scheme_mix_criterion_incentives do |t|
      t.references :scheme_mix_criterion, foreign_key: true, index: { name: 'index_incentives_to_scheme_mix_criteria' }
      t.references :scheme_criterion_incentive, foreign_key: true, index: { name: 'index_incentives_to_scheme_criterion_incentives' }
      t.boolean :incentive_scored, default: false

      t.timestamps null: false
    end
  end
end
