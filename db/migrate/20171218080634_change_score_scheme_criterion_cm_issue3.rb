class ChangeScoreSchemeCriterionCmIssue3 < ActiveRecord::Migration
  def change
    SchemeCriterion.joins(scheme_category: [scheme: [development_types: [:certificate]]]).where(certificates: {gsas_version: '2.1 issue 3', certification_type: Certificate.certification_types[:construction_certificate]}).update_all(minimum_score: -1.0, maximum_score: 3.0, minimum_valid_score: -1.0)
  end
end
