require 'file_size_validator'

class AuditLog < ApplicationRecord
  belongs_to :auditable, polymorphic: true, optional: true
  belongs_to :user, optional: true
  belongs_to :project, optional: true
  belongs_to :certification_path, optional: true
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
    if user.is_system_admin? || user.is_gsb_manager? || user.is_gsb_top_manager? || user.is_gsb_admin?
      all
    else
      where(project: user.projects)
    end
  }
end