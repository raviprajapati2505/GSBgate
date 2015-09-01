class Project < AuditableRecord
  belongs_to :owner, class_name: 'User', inverse_of: :owned_projects
  has_many :project_authorizations, dependent: :delete_all
  has_many :users, -> { where('project_authorizations.role < 3') },  through: :project_authorizations
  has_many :certifiers, -> { where('project_authorizations.role > 2') }, through: :project_authorizations, source: :user
  has_many :managers, -> { where('project_authorizations.role = 1') }, through: :project_authorizations, source: :user
  has_many :certification_paths

  validates :name, presence: true
  validates :address, presence: true
  validates :location, presence: true
  validates :country, presence: true
  validates :gross_area, numericality: { greater_than_or_equal_to: 0 }
  validates :certified_area, numericality: { greater_than_or_equal_to: 0 }
  validates :carpark_area, numericality: { greater_than_or_equal_to: 0 }
  validates :project_site_area, numericality: { greater_than_or_equal_to: 0 }
  validates :construction_year, numericality: { only_integer: true, greater_than: 0 }
  validates :terms_and_conditions_accepted, acceptance: true

  after_initialize :init

  scope :for_owner, ->(user) {
    where(owner: user)
  }

  scope :for_authorized_user, ->(user) {
    includes(:project_authorizations)
    .where(project_authorizations: { user: user })
  }

  def role_for_user(user)
    project_authorizations.each do |project_authorization|
      if project_authorization.user == user
        return project_authorization.role
      end
    end
    return false
  end

  def certifier_manager_assigned?
    project_authorizations.each do |project_authorization|
      if project_authorization.certifier_manager?
        return true
      end
    end
    return false
  end

  def init
    # Set default code
    self.code ||= 'TBC'

    # Set default latlng location to Doha, Qatar
    self.latlng ||= 'POINT(51.53043679999996 25.2916097)'
  end
end
