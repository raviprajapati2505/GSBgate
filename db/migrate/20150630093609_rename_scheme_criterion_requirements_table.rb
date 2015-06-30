class RenameSchemeCriterionRequirementsTable < ActiveRecord::Migration
  def change
    rename_table :scheme_criterion_requirements, :scheme_criteria_requirements
  end
end
