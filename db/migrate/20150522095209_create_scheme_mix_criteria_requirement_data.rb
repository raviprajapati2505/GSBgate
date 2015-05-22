class CreateSchemeMixCriteriaRequirementData < ActiveRecord::Migration
  def change
    create_table :scheme_mix_criteria_requirement_data do |t|
      t.references :scheme_mix_criterion, index: false, foreign_key: true
      t.references :requirement_datum, index: false, foreign_key: true

      t.timestamps null: false
    end

    add_index(:scheme_mix_criteria_requirement_data, :scheme_mix_criterion_id, unique: true, name: 'by_scheme_mix_criterion')
    add_index(:scheme_mix_criteria_requirement_data, :requirement_datum_id, unique: true, name: 'by_requirement_datum')
  end
end
