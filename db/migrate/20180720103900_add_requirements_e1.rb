class AddRequirementsE1 < ActiveRecord::Migration
  def change
    requirement_1 = Requirement.create!(name: 'Energy Performance Evaluation Calculator')
    requirement_2 = Requirement.create!(name: 'Design drawings')
    requirement_3 = Requirement.create!(name: 'Relevant mechanical, electrical, and plumbing (MEP) drawings')
    requirement_4 = Requirement.create!(name: 'Tenant lease agreement which includes a conditional energy demand performance target score for all future tenants')

    SchemeCriteriaRequirement.create!(scheme_criterion_id: 3332, requirement: requirement_1)
    SchemeCriteriaRequirement.create!(scheme_criterion_id: 3332, requirement: requirement_2)
    SchemeCriteriaRequirement.create!(scheme_criterion_id: 3332, requirement: requirement_3)
    SchemeCriteriaRequirement.create!(scheme_criterion_id: 3332, requirement: requirement_4)
  end
end
