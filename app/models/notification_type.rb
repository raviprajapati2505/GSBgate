class NotificationType < ActiveRecord::Base

  has_many :notification_types_users, dependent: :delete_all

  NEW_USER_COMMENT = 1
  PROJECT_CREATED = 2
  CERTIFICATE_APPLIED = 3
  CERTIFICATE_ACTIVATED = 4
  CERTIFICATE_SUBMITTED_FOR_SCREENING = 5
  CERTIFICATE_SCREENED = 6
  CERTIFICATE_PCR_SELECTED = 7
  CERTIFICATE_PCR_APPROVED = 8
  CERTIFICATE_SUBMITTED_FOR_VERIFICATION = 9
  CERTIFICATE_VERIFIED = 10
  CERTIFICATE_APPEALED = 11
  CERTIFICATE_APPEAL_APPROVED = 12
  CERTIFICATE_SUBMITTED_FOR_VERIFICATION_AFTER_APPEAL = 13
  CERTIFICATE_VERIFIED_AFTER_APPEAL = 14
  CERTIFICATE_APPROVED_BY_MNGT = 15
  CERTIFICATE_ISSUED = 16
  CRITERION_SUBMITTED = 17
  CRITERION_VERIFIED = 18
  CRITERION_APPEALED = 19
  CRITERION_SUBMITTED_AFTER_APPEAL = 20
  CRITERION_VERIFIED_AFTER_APPEAL = 21
  REQUIREMENT_PROVIDED = 22
  NEW_DOCUMENT_WAITING_FOR_APPROVAL = 23
  DOCUMENT_APPROVED = 24
  NEW_TASK = 25

  scope :for_user, ->(user_id) {
    joins(:notification_types_users).where(notification_types_users: {user_id: user_id})
  }

  scope :for_project, ->(project_id) {
    joins(:notification_types_users).where(notification_types_users: {project_id: project_id})
  }

  scope :for_general_level, ->() {
    where(project_level: false)
  }

end
