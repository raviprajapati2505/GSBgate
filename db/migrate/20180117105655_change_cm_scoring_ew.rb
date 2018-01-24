class ChangeCmScoringEw < ActiveRecord::Migration
  def change
    add_column :scheme_mix_criteria, :targeted_score_b, :decimal, precision: 3, scale: 1
    add_column :scheme_mix_criteria, :submitted_score_b, :decimal, precision: 3, scale: 1
    add_column :scheme_mix_criteria, :achieved_score_b, :decimal, precision: 3, scale: 1
    add_column :scheme_mix_criteria, :incentive_scored_b, :boolean, default: false

    add_column :scheme_criteria, :weight_b, :decimal, precision: 5, scale: 2, default: 0.0
    add_column :scheme_criteria, :scores_b, :string
    add_column :scheme_criteria, :minimum_score_b, :decimal, precision: 4, scale: 1
    add_column :scheme_criteria, :maximum_score_b, :decimal, precision: 4, scale: 1
    add_column :scheme_criteria, :minimum_valid_score_b, :decimal, precision: 4, scale: 1
    add_column :scheme_criteria, :incentive_weight_minus_1_b, :decimal, precision: 5, scale: 2, default: 0.0
    add_column :scheme_criteria, :incentive_weight_0_b, :decimal, precision: 5, scale: 2, default: 0.0
    add_column :scheme_criteria, :incentive_weight_1_b, :decimal, precision: 5, scale: 2, default: 0.0
    add_column :scheme_criteria, :incentive_weight_2_b, :decimal, precision: 5, scale: 2, default: 0.0
    add_column :scheme_criteria, :incentive_weight_3_b, :decimal, precision: 5, scale: 2, default: 0.0
    add_column :scheme_criteria, :calculate_incentive_b, :boolean, default: false

    # OE.1
    scheme_criteria = SchemeCriterion.joins(scheme_category: [scheme: [development_types: [:certificate]]]).where(name: 'Dust Control', number: 1, scheme_categories: {code: 'OE'}).where("certificates.certificate_type = 1 AND certificates.gsas_version = 'v2.1 Issue 3.0' AND certificates.certification_type IN (31, 32, 33)").distinct
    scheme_criteria.each do |scheme_criterion|
      scheme_criterion.incentive_weight_0 = 2.0
      scheme_criterion.incentive_weight_1 = 2.0
      scheme_criterion.incentive_weight_2 = 2.0
      scheme_criterion.incentive_weight_3 = 2.0
      scheme_criterion.calculate_incentive = false
      scheme_criterion.assign_incentive_manually = true
      scheme_criterion.save!
    end

    # MO.4
    scheme_criteria = SchemeCriterion.joins(scheme_category: [scheme: [development_types: [:certificate]]]).where(name: 'Workers Accommodation', number: 4, scheme_categories: {code: 'MO'}).where("certificates.certificate_type = 1 AND certificates.gsas_version = 'v2.1 Issue 3.0' AND certificates.certification_type IN (31, 32, 33)").distinct
    scheme_criteria.each do |scheme_criterion|
      scheme_criterion.incentive_weight_1 = 2.0
      scheme_criterion.incentive_weight_2 = 3.0
      scheme_criterion.incentive_weight_3 = 4.0
      scheme_criterion.save!
    end

    # E.1 and E.2
    scheme_criteria = SchemeCriterion.joins(scheme_category: {scheme: {development_types: :certificate}}).where(scheme_categories: {code: 'E'}).where("certificates.certificate_type = 1 AND certificates.gsas_version = 'v2.1 Issue 3.0' AND certificates.certification_type IN (31, 32, 33)").distinct
    scheme_criteria.each do |scheme_criterion|
      scheme_criterion.weight = 5.0
      scheme_criterion.weight_b = scheme_criterion.weight
      scheme_criterion.scores_b = YAML.load(scheme_criterion.scores.to_s)
      scheme_criterion.minimum_score_b = scheme_criterion.minimum_score
      scheme_criterion.maximum_score_b = scheme_criterion.maximum_score
      scheme_criterion.minimum_valid_score_b = scheme_criterion.minimum_valid_score
      scheme_criterion.incentive_weight_1_b = 1.5
      scheme_criterion.incentive_weight_2_b = 1.5
      scheme_criterion.incentive_weight_3_b = 1.5
      scheme_criterion.calculate_incentive = false
      scheme_criterion.calculate_incentive_b = false
      scheme_criterion.assign_incentive_manually = true
      scheme_criterion.save!
    end

    # W.1 and W.2
    scheme_criteria = SchemeCriterion.joins(scheme_category: {scheme: {development_types: :certificate}}).where(scheme_categories: {code: 'W'}).where("certificates.certificate_type = 1 AND certificates.gsas_version = 'v2.1 Issue 3.0' AND certificates.certification_type IN (31, 32, 33)").distinct
    scheme_criteria.each do |scheme_criterion|
      scheme_criterion.weight = 3.0
      scheme_criterion.weight_b = scheme_criterion.weight
      scheme_criterion.scores_b = YAML.load(scheme_criterion.scores.to_s)
      scheme_criterion.minimum_score_b = scheme_criterion.minimum_score
      scheme_criterion.maximum_score_b = scheme_criterion.maximum_score
      scheme_criterion.minimum_valid_score_b = scheme_criterion.minimum_valid_score
      scheme_criterion.incentive_weight_1_b = 1.0
      scheme_criterion.incentive_weight_2_b = 1.0
      scheme_criterion.incentive_weight_3_b = 1.0
      scheme_criterion.calculate_incentive = false
      scheme_criterion.calculate_incentive_b = false
      scheme_criterion.assign_incentive_manually = true
      scheme_criterion.save!
    end
  end
end
