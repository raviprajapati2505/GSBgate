class Notification < ActiveRecord::Base
  belongs_to :user

  after_initialize :init

  default_scope { order(created_at: :desc) }

  scope :for_user, ->(user) {
    where(user: user)
  }

  scope :unread, -> {
    where(read: false)
  }

  def init
    self.read ||= false
  end
end
