class AuditLog < ActiveRecord::Base
  belongs_to :auditable, polymorphic: true
  belongs_to :user
  belongs_to :project
  belongs_to :certification_path
  has_one :audit_log_visibility

  MAXIMUM_DOCUMENT_FILE_SIZE = 100 # in MB

  default_scope { order(id: :desc) }

  mount_uploader :attachment_file, AuditLogAttachmentUploader

  validates :attachment_file, file_size: {maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }

  scope :for_auditable, ->(auditable) {
    where(auditable: auditable)
  }

  scope :with_user_comment, -> {
    where.not(user_comment: nil)
  }

  scope :for_user_projects, ->(user) {
    if user.system_admin? || user.gsas_trust_manager? || user.gsas_trust_top_manager? || user.gsas_trust_admin?
      all
    else
      where(project: user.projects)
    end
  }
end