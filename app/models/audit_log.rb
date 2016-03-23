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
    if user.system_admin? || user.gsas_trust_manager? || user.gsas_trust_top_manager? || user.gsas_trust_admin?
      all
    else
      where(project: user.projects)
    end
  }
end