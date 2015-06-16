class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  enum role: [ :system_admin, :user ]

  has_many :owned_projects, class_name: 'Project', inverse_of: :owner
  has_many :documents
  has_many :project_authorizations
  has_many :projects, through: :project_authorizations
  has_many :requirement_data

  default_scope { order(email: :asc) }

  scope :not_owning_project, ->(project) {
    where.not(id: project.owner_id)
  }

  scope :not_authorized_for_project, ->(project) {
    where.not('exists(select id from project_authorizations where user_id = users.id and project_id = ?)', project.id)
  }

  scope :without_permissions_for_project, ->(project) {
    where(role: 1) & not_owning_project(project) & not_authorized_for_project(project)
  }

  scope :authorized_for_project, ->(project) {
    joins(:project_authorizations).where(project_authorizations: {project_id: project.id})
  }

  before_validation :assign_default_role, on: :create

  validates :role, inclusion: User.roles.keys

  private
  def assign_default_role
    self.role = :user if self.role.nil?
  end

end
