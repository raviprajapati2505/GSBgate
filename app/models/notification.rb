class Notification < ActiveResource
  belongs_to :user
  belongs_to :project

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
