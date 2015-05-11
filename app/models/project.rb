class Project < ActiveRecord::Base
  # reference to project owner
  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'
  has_many :project_authorizations
  has_many :users, through: :project_authorizations

  belongs_to :project_status
  has_many :certification_paths

  scope :for_user, ->(user) {
    for_owner(user) | for_authorized_user(user)
  }

  scope :for_owner, ->(user) {
    where(owner: user)
  }

  scope :for_authorized_user, -> (user) {
    includes(:project_authorizations)
    .where(project_authorizations: { user: user })
  }


end
