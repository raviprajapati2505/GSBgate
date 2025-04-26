class DemeritFlag < ApplicationRecord
  belongs_to :user

  # scopes
  default_scope { order(created_at: :asc) }

  mount_uploader :gsb_notification, UserSubmittalUploader
  mount_uploader :practitioner_acknowledge, UserSubmittalUploader
end
