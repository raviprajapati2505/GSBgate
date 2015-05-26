class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  enum role: [ :system_admin, :certifier_project_manager, :certifier_team_member, :project_team_member, :enterprise_licence, :operations_inspector, :anonymous ]

  has_many :owned_projects, class_name: 'Project', inverse_of: :owner
  has_many :project_authorizations
  has_many :projects, through: :project_authorizations

  default_scope { order(email: :asc) }

  scope :with_role_different_from, ->(role) {
    where.not(role: role)
  }

  scope :with_no_role, -> {
    where(role: nil)
  }

  scope :with_no_admin_role, -> {
    with_role_different_from(User.roles[:system_admin]) | with_no_role
  }

  scope :without_permissions_for_project, ->(project) {
    where(role: [ 3, 4 ])
    .includes(:owned_projects).where(projects: {user_id: nil})
    .includes(:project_authorizations).where('project_authorizations.project_id is null or project_authorizations.project_id <> ?', project.id)
  }

  before_validation :assign_default_role, on: :create

  validates :role, inclusion: User.roles.keys

  private
  def assign_default_role
    self.role = :anonymous if self.role.nil?
  end

end
