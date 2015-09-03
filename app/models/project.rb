class Project < AuditableRecord
  belongs_to :owner, class_name: 'User', inverse_of: :owned_projects
  has_many :projects_users, dependent: :delete_all
  has_many :users, -> { where('projects_users.role < 3') },  through: :projects_users
  has_many :certifiers, -> { where('projects_users.role > 2') }, through: :projects_users, source: :user
  has_many :managers, -> { where('projects_users.role = 1') }, through: :projects_users, source: :user
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

  def role_for_user(user)
    projects_users.each do |projects_user|
      if projects_user.user == user
        return projects_user.role
      end
    end
    return false
  end

  def certifier_manager_assigned?
    projects_users.each do |projects_user|
      if projects_user.certifier_manager?
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
