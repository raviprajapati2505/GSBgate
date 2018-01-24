class ChangeCmScoring < ActiveRecord::Migration
  def change
    # Add column calculate_incentive and assign_incentive_manually to scheme_criteria
    add_column :scheme_criteria, :calculate_incentive, :boolean, default: true
    add_column :scheme_criteria, :assign_incentive_manually, :boolean, default: false

    # migrate existing scheme_mix_criterion data
    SchemeMixCriterion.joins(scheme_criterion: {scheme_category: {scheme: {development_types: :certificate}}}).where.not(scheme_criteria: {name: 'Dust Control', number: 1}, 'scheme_categories.code' => 'OE').where.not("certificates.certificate_type = 1 AND certificates.gsas_version = 'v2.1 Issue 3.0' AND certificates.certification_type IN (30, 31, 32, 33)").update_all(incentive_scored: true)

    remove_column :scheme_criteria, :incentive_weight
  end
end
