class CreateSchemeMixCriteriaRequirementData < ActiveRecord::Migration[7.0]
  def change
    create_table :scheme_mix_criteria_requirement_data do |t|
      t.references :scheme_mix_criterion, foreign_key: true, index: false
      t.references :requirement_datum, foreign_key: true, index: false

      t.timestamps null: false
    end
  end
end
