class RenameScoreFields < ActiveRecord::Migration
  def change
    rename_column :scheme_criteria, :weight, :weight_a
    rename_column :scheme_criteria, :scores, :scores_a
    rename_column :scheme_criteria, :minimum_score, :minimum_score_a
    rename_column :scheme_criteria, :maximum_score, :maximum_score_a
    rename_column :scheme_criteria, :minimum_valid_score, :minimum_valid_score_a
    rename_column :scheme_criteria, :incentive_weight_minus_1, :incentive_weight_minus_1_a
    rename_column :scheme_criteria, :incentive_weight_0, :incentive_weight_0_a
    rename_column :scheme_criteria, :incentive_weight_1, :incentive_weight_1_a
    rename_column :scheme_criteria, :incentive_weight_2, :incentive_weight_2_a
    rename_column :scheme_criteria, :incentive_weight_3, :incentive_weight_3_a
    rename_column :scheme_criteria, :calculate_incentive, :calculate_incentive_a
    rename_column :scheme_criteria, :assign_incentive_manually, :assign_incentive_manually_a
    rename_column :scheme_criteria, :label, :label_a

    rename_column :scheme_mix_criteria, :targeted_score, :targeted_score_a
    rename_column :scheme_mix_criteria, :submitted_score, :submitted_score_a
    rename_column :scheme_mix_criteria, :achieved_score, :achieved_score_a
    rename_column :scheme_mix_criteria, :incentive_scored, :incentive_scored_a

    scheme_criteria = SchemeCriterion.joins(scheme_category: {scheme: {development_types: :certificate}}).where(scheme_categories: {code: 'E'}).where("certificates.certificate_type = 1 AND certificates.gsas_version = 'v2.1 Issue 3.0' AND certificates.certification_type IN (31, 32, 33)").distinct
    scheme_criteria.each do |scheme_criterion|
      scheme_criterion.assign_incentive_manually_a = false
      scheme_criterion.assign_incentive_manually_b = true
      scheme_criterion.label_a = 'Calculated'
      scheme_criterion.label_b = 'Measured'
      scheme_criterion.save!
    end

    scheme_criteria = SchemeCriterion.joins(scheme_category: {scheme: {development_types: :certificate}}).where(scheme_categories: {code: 'W'}).where("certificates.certificate_type = 1 AND certificates.gsas_version = 'v2.1 Issue 3.0' AND certificates.certification_type IN (31, 32, 33)").distinct
    scheme_criteria.each do |scheme_criterion|
      scheme_criterion.assign_incentive_manually_a = false
      scheme_criterion.assign_incentive_manually_b = true
      scheme_criterion.label_a = 'Calculated'
      scheme_criterion.label_b = 'Measured'
      scheme_criterion.save!
    end

    execute("update certification_paths set expires_at = (current_timestamp '1' year * duration) where expires_at is null")

  end
end
