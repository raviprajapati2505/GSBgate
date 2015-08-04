class Project < ActiveRecord::Base

  belongs_to :owner, class_name: 'User', inverse_of: :owned_projects
  has_many :project_authorizations, dependent: :delete_all
  has_many :users, -> { where('project_authorizations.role < 3') },  through: :project_authorizations
  has_many :certifiers, -> { where('project_authorizations.role > 2') }, through: :project_authorizations, source: :user
  has_many :certification_paths
  has_many :notifications

  after_initialize :init

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

  def init
    # Set default code
    self.code ||= 'TBC'

    # Set default latlng location to Doha, Qatar
    self.latlng ||= 'POINT(51.53043679999996 25.2916097)'
  end
end
