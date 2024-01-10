class CreateSchemeCriteriaRequirements < ActiveRecord::Migration[7.0]
  def change
    create_table :scheme_criteria_requirements do |t|
      t.references :scheme_criterion, foreign_key: true, index: true
      t.references :requirement, foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
