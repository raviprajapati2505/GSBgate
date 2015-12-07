class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  enum role: { system_admin: 0, user: 1, gord_top_manager: 2, gord_manager: 3 }

  has_many :owned_projects, class_name: 'Project', inverse_of: :owner
  has_many :documents
  has_many :scheme_mix_criteria_documents
  has_many :projects_users, dependent: :delete_all
  has_many :projects, through: :projects_users
  has_many :requirement_data, dependent: :nullify
  has_many :scheme_mix_criteria, inverse_of: :certifier, foreign_key: 'certifier_id'
  has_many :tasks, dependent: :destroy
  has_many :audit_logs
  has_many :notification_types_users, dependent: :delete_all
  has_many :notification_types, through: :notification_types_users

  default_scope { order(email: :asc) }

  scope :not_owning_project, ->(project) {
    where.not(id: project.owner_id)
  }

  scope :not_authorized_for_project, ->(project) {
    where.not('exists(select id from projects_users where user_id = users.id and project_id = ?)', project.id)
  }

  scope :without_permissions_for_project, ->(project) {
    where(role: 1) & not_owning_project(project) & not_authorized_for_project(project)
  }

  scope :authorized_for_project, ->(project) {
    joins(:projects_users).where(projects_users: {project_id: project.id})
  }

  scope :with_assessor_project_role, -> {
    where('projects_users.role in (0, 1)')
  }

  scope :with_certifier_project_role, -> {
    where('projects_users.role in (3, 4)')
  }

  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  def certifier_manager?(project)
    ProjectsUser.exists?(project: project, user: self, role: ProjectsUser.roles[:certifier_manager])
  end

  def project_manager?(project)
    ProjectsUser.exists?(project: project, user: self, role: ProjectsUser.roles[:project_manager])
  end

  def enterprise_account?(project)
    ProjectsUser.exists?(project: project, user: self, role: ProjectsUser.roles[:enterprise_account])
  end

  def project_team_member?(project)
    ProjectsUser.exists?(project: project, user: self, role: ProjectsUser.roles[:project_team_member])
  end

  def certifier?(project)
    ProjectsUser.exists?(project: project, user: self, role: ProjectsUser.roles[:certifier])
  end

  # Returns the humanized role of the user in a project.
  # Returns the humanized system role of the user if the user isn't linked to the project.
  def humanized_project_role(project)
    project_user = ProjectsUser.find_by(project: project, user: self)
    return project_user.present? ? project_user.role.humanize : self.role.humanize
  end

  # Updates the current password of a user
  def attempt_set_password(params)
    p = {}
    p[:password] = params[:password]
    p[:password_confirmation] = params[:password_confirmation]
    update_attributes(p)
  end

  def password_required?
    # Password is required if it is being set, but not for new records
    if !persisted?
      false
    else
      !password.nil? || !password_confirmation.nil?
    end
  end

  def only_if_unconfirmed
    pending_any_confirmation {yield}
  end

  before_validation :assign_default_role, on: :create

  validates :role, inclusion: User.roles.keys

  private
  def assign_default_role
    self.role = :user if self.role.nil?
  end

end
