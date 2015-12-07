class AuditLog < ActiveRecord::Base
  belongs_to :auditable, polymorphic: true
  belongs_to :user
  belongs_to :project
  belongs_to :certification_path

  default_scope { order(id: :desc) }

  scope :for_auditable, ->(auditable) {
    where(auditable: auditable)
  }

  scope :with_user_comment, -> {
    where.not(user_comment: nil)
  }

  scope :for_user_projects, ->(user) {
    if user.system_admin? || user.gord_manager? || user.gord_top_manager?
      all
    else
      where(project: user.projects)
    end
  }
end