class ChangeCmScoring < ActiveRecord::Migration
  def change
    # Add column calculate_incentive and assign_incentive_manually to scheme_criteria
    add_column :scheme_criteria, :calculate_incentive, :boolean, default: true
    add_column :scheme_criteria, :assign_incentive_manually, :boolean, default: false

    # migrate existing scheme_mix_criterion data
    SchemeMixCriterion.joins(scheme_criterion: {scheme_category: {scheme: {development_types: :certificate}}}).where.not(scheme_criteria: {name: 'Dust Control', number: 1}, 'scheme_categories.code' => 'OE').where.not("certificates.certificate_type = 1 AND certificates.gsas_version = 'v2.1 Issue 3.0' AND certificates.certification_type IN (30, 31, 32, 33)").update_all(incentive_scored: true)

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

    remove_column :scheme_criteria, :incentive_weight
  end
end
