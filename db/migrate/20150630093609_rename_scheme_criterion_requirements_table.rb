class RenameSchemeCriterionRequirementsTable < ActiveRecord::Migration[4.2]
  def change
    rename_table :scheme_criterion_requirements, :scheme_criteria_requirements
  end
end
