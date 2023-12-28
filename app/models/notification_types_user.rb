class NotificationTypesUser < ApplicationRecord
  belongs_to :notification_type, optional: true
  belongs_to :user, optional: true
  belongs_to :project, optional: true
end
