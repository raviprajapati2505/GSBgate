class Project < ActiveRecord::Base

  belongs_to :owner, class_name: 'User', inverse_of: :owned_projects
  belongs_to :client, class_name: 'User'
  belongs_to :certifier, class_name: 'User'
  has_many :project_authorizations
  has_many :users, through: :project_authorizations
  has_many :certification_paths

  after_initialize :init

  scope :for_user, ->(user) {
    for_owner(user) | for_client(user) | for_authorized_user(user)
  }

  scope :for_owner, ->(user) {
    where(owner: user)
  }

  scope :for_client, ->(user) {
    includes(:project_authorizations)
    .where(project_authorizations: {user: user, role: ['enterprise_account', ProjectAuthorization.roles[:enterprise_account]]})
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
