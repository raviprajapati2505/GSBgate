class MarkAllExistingScreenedSchemeMixCriteriaAsScreened < ActiveRecord::Migration
  def change
    # Mark all criteria of already screened existing certification paths as "screened"
    screened_certfication_path_ids = CertificationPath.where.not(certification_path_status_id: [CertificationPathStatus::ACTIVATING, CertificationPathStatus::SUBMITTING, CertificationPathStatus::SCREENING]).pluck(:id)
    screened_scheme_mixes = SchemeMix.where(certification_path_id: screened_certfication_path_ids).pluck(:id)
    SchemeMixCriterion.where(scheme_mix_id: screened_scheme_mixes).update_all(screened: true)
  end
end
