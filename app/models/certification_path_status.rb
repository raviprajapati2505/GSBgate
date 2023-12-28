class CertificationPathStatus < ApplicationRecord
  has_many :certification_paths
  has_many :cgp_certification_path_documents, dependent: :destroy
  has_many :documents, dependent: :destroy


  scope :status_scope, ->(status_scopes) {
    where(id: status_scopes)
  }

  # Statuses
  ACTIVATING = 1
  SUBMITTING = 2
  SCREENING = 3
  SUBMITTING_AFTER_SCREENING = 4
  VERIFYING = 7
  ACKNOWLEDGING = 8
  PROCESSING_APPEAL_PAYMENT = 9
  SUBMITTING_AFTER_APPEAL = 10
  VERIFYING_AFTER_APPEAL = 11
  ACKNOWLEDGING_AFTER_APPEAL = 12
  APPROVING_BY_MANAGEMENT = 13
  APPROVING_BY_TOP_MANAGEMENT = 14
  CERTIFIED = 15
  NOT_CERTIFIED = 16
  CERTIFICATE_IN_PROCESS = 17
  # ------------------------------------------------------------------------
  # STATUSES GROUPED BY 'PROGRESS'
  # ------------------------------------------------------------------------

  STATUSES_IN_PROGRESS = [
      CertificationPathStatus::ACTIVATING,
      CertificationPathStatus::SUBMITTING,
      CertificationPathStatus::SCREENING,
      CertificationPathStatus::SUBMITTING_AFTER_SCREENING,
      CertificationPathStatus::VERIFYING,
      CertificationPathStatus::ACKNOWLEDGING,
      CertificationPathStatus::PROCESSING_APPEAL_PAYMENT,
      CertificationPathStatus::SUBMITTING_AFTER_APPEAL,
      CertificationPathStatus::VERIFYING_AFTER_APPEAL,
      CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL,
      CertificationPathStatus::APPROVING_BY_MANAGEMENT,
      CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT,
      CertificationPathStatus::CERTIFICATE_IN_PROCESS
  ]

  STATUSES_ACTIVATED = [
      CertificationPathStatus::SUBMITTING,
      CertificationPathStatus::SCREENING,
      CertificationPathStatus::SUBMITTING_AFTER_SCREENING,
      CertificationPathStatus::VERIFYING,
      CertificationPathStatus::ACKNOWLEDGING,
      CertificationPathStatus::PROCESSING_APPEAL_PAYMENT,
      CertificationPathStatus::SUBMITTING_AFTER_APPEAL,
      CertificationPathStatus::VERIFYING_AFTER_APPEAL,
      CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL,
      CertificationPathStatus::APPROVING_BY_MANAGEMENT,
      CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT,
      CertificationPathStatus::CERTIFIED,
      CertificationPathStatus::NOT_CERTIFIED,
      CertificationPathStatus::CERTIFICATE_IN_PROCESS
  ]

  STATUSES_COMPLETED = [
      CertificationPathStatus::CERTIFIED,
      CertificationPathStatus::NOT_CERTIFIED,
      CertificationPathStatus::CERTIFICATE_IN_PROCESS
  ]

  # ------------------------------------------------------------------------
  # STATUSES GROUPED BY 'SIDE'
  # ------------------------------------------------------------------------
  STATUSES_AT_PROJECT_TEAM_SIDE = [
      CertificationPathStatus::SUBMITTING,
      CertificationPathStatus::SUBMITTING_AFTER_SCREENING,
      CertificationPathStatus::ACKNOWLEDGING,
      CertificationPathStatus::SUBMITTING_AFTER_APPEAL,
      CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL
  ]

  STATUSES_AT_ADMIN_SIDE = [
      CertificationPathStatus::ACTIVATING,
      CertificationPathStatus::PROCESSING_APPEAL_PAYMENT,
  ]

  STATUSES_AT_CERTIFIER_SIDE = [
      CertificationPathStatus::SCREENING,
      CertificationPathStatus::VERIFYING,
      CertificationPathStatus::VERIFYING_AFTER_APPEAL
  ]

  STATUSES_AT_MANAGEMENT_SIDE = [
      CertificationPathStatus::APPROVING_BY_MANAGEMENT,
      CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT,
      CertificationPathStatus::CERTIFICATE_IN_PROCESS
  ]

  STATUSES_AT_GSAS_TRUST_TEAM_SIDE = STATUSES_AT_CERTIFIER_SIDE + STATUSES_AT_ADMIN_SIDE + STATUSES_AT_MANAGEMENT_SIDE

  # ------------------------------------------------------------------------
  # STATUSES GROUPED BY 'STAGE'
  # ------------------------------------------------------------------------
  # this function is used to toggle the visibility of the achieved score
  STATUSES_IN_PRE_VERIFICATION = [
      CertificationPathStatus::ACTIVATING,
      CertificationPathStatus::SUBMITTING,
      CertificationPathStatus::SCREENING,
      CertificationPathStatus::SUBMITTING_AFTER_SCREENING,
  ]

  # This function is used for toggling form elements writable state in the certification path flow
  STATUSES_IN_SUBMISSION = [
      CertificationPathStatus::SUBMITTING,
      CertificationPathStatus::SUBMITTING_AFTER_SCREENING,
      CertificationPathStatus::SUBMITTING_AFTER_APPEAL
  ]

  # Used for toggling writability of form elements in the certification path flow
  STATUSES_IN_VERIFICATION = [
      # CertificationPathStatus::SCREENING,
      CertificationPathStatus::VERIFYING,
      CertificationPathStatus::VERIFYING_AFTER_APPEAL
  ]

  STATUSES_IN_ACKNOWLEDGING = [
      CertificationPathStatus::ACKNOWLEDGING,
      CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL
  ]

  def self.at_gsas_trust_team_side?(id)
    STATUSES_AT_GSAS_TRUST_TEAM_SIDE.include?(id)
  end

end
