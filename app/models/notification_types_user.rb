class NotificationTypesUser < ActiveRecord::Base
  belongs_to :notification_type
  belongs_to :user
end
