class CertificationPathStatus < ActiveRecord::Base
  has_many :certification_paths
  enum waiting_for: { project_manager: 0, certifier_manager: 1, system_admin: 2, gord_top_manager: 3 }

  # Statuses
  ACTIVATING = 1
  SUBMITTING = 2
  SCREENING = 3
  SUBMITTING_AFTER_SCREENING = 4
  PROCESSING_PCR_PAYMENT = 5
  SUBMITTING_PCR = 6
  VERIFYING = 7
  ACKNOWLEDGING = 8
  PROCESSING_APPEAL_PAYMENT = 9
  SUBMITTING_AFTER_APPEAL = 10
  VERIFYING_AFTER_APPEAL = 11
  ACKNOWLEDGING_AFTER_APPEAL = 12
  APPROVING_BY_MANAGEMENT = 13
  CERTIFIED = 14
  NOT_CERTIFIED = 15
end
