class AuditLog < ActiveRecord::Base
  belongs_to :auditable, polymorphic: true
  belongs_to :user
  belongs_to :project

  default_scope { order(created_at: :desc) }

  scope :for_auditable, ->(auditable) {
    where(auditable_type: auditable.class.name, auditable_id: auditable.id)
  }
end