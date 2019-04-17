class AddAssignIncentiveManuallyToSchemeCriterion < ActiveRecord::Migration[4.2]
  def change
    add_column :scheme_criteria, :assign_incentive_manually_b, :boolean, default: false
    add_column :scheme_criteria, :label, :string
    add_column :scheme_criteria, :label_b, :string

    scheme_criteria = SchemeCriterion.joins(scheme_category: {scheme: {development_types: :certificate}}).where(scheme_categories: {code: 'E'}).where("certificates.certificate_type = 1 AND certificates.gsas_version = 'v2.1 Issue 3.0' AND certificates.certification_type IN (31, 32, 33)").distinct
    scheme_criteria.each do |scheme_criterion|
      # scheme_criterion.weight = scheme_criterion.weight / 2
      # scheme_criterion.weight_b = scheme_criterion.weight
      # scheme_criterion.scores_b = scheme_criterion.scores
      # scheme_criterion.minimum_score_b = scheme_criterion.minimum_score
      # scheme_criterion.maximum_score_b = scheme_criterion.maximum_score
      # scheme_criterion.minimum_valid_score_b = scheme_criterion.minimum_valid_score
      # scheme_criterion.incentive_weight_1_b = 1.5
      # scheme_criterion.incentive_weight_2_b = 1.5
      # scheme_criterion.incentive_weight_3_b = 1.5
      # scheme_criterion.calculate_incentive = false
      # scheme_criterion.calculate_incentive_b = false
      scheme_criterion.assign_incentive_manually = false
      scheme_criterion.assign_incentive_manually_b = true
      scheme_criterion.label = 'Calculated'
      scheme_criterion.label_b = 'Measured'
      scheme_criterion.save!
    end

    scheme_criteria = SchemeCriterion.joins(scheme_category: {scheme: {development_types: :certificate}}).where(scheme_categories: {code: 'W'}).where("certificates.certificate_type = 1 AND certificates.gsas_version = 'v2.1 Issue 3.0' AND certificates.certification_type IN (31, 32, 33)").distinct
    scheme_criteria.each do |scheme_criterion|
      # scheme_criterion.weight = scheme_criterion.weight / 2
      # scheme_criterion.weight_b = scheme_criterion.weight
      # scheme_criterion.scores_b = scheme_criterion.scores
      # scheme_criterion.minimum_score_b = scheme_criterion.minimum_score
      # scheme_criterion.maximum_score_b = scheme_criterion.maximum_score
      # scheme_criterion.minimum_valid_score_b = scheme_criterion.minimum_valid_score
      # scheme_criterion.incentive_weight_1_b = 1.0
      # scheme_criterion.incentive_weight_2_b = 1.0
      # scheme_criterion.incentive_weight_3_b = 1.0
      # scheme_criterion.calculate_incentive = false
      # scheme_criterion.calculate_incentive_b = false
      scheme_criterion.assign_incentive_manually = false
      scheme_criterion.assign_incentive_manually_b = true
      scheme_criterion.label = 'Calculated'
      scheme_criterion.label_b = 'Measured'
      scheme_criterion.save!
    end
  end
end
