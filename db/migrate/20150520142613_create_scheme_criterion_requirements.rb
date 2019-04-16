class CreateSchemeCriterionRequirements < ActiveRecord::Migration[4.2]
  def change
    create_table :scheme_criterion_requirements do |t|
      t.references :scheme_criterion, index: true, foreign_key: true
      t.references :requirement, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
