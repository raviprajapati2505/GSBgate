class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  enum role: [ :system_admin, :certifier, :assessor, :enterprise_licence ]

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
    where(role: 2)
    .includes(:owned_projects).where(projects: {user_id: nil})
        .where.not('exists(select id from project_authorizations where user_id = users.id and project_id = ?)', project.id)
  }

  before_validation :assign_default_role, on: :create

  validates :role, inclusion: User.roles.keys

  private
  def assign_default_role
    self.role = :assessor if self.role.nil?
  end

end
