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

  scope :with_certifier_role, -> {
    where(role: 1)
  }

  scope :with_assessor_role, -> {
    where(role: 2)
  }

  scope :with_enterprise_role, -> {
    where(role: 3)
  }

  scope :without_permissions_for_project, ->(project) {
    where(role: 2)
    .includes(:owned_projects).where(projects: {owner_id: nil})
        .where.not('exists(select id from project_authorizations where user_id = users.id and project_id = ?)', project.id)
  }

  before_validation :assign_default_role, on: :create

  validates :role, inclusion: User.roles.keys

  private
  def assign_default_role
    self.role = :assessor if self.role.nil?
  end

end
