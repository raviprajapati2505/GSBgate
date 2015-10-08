class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  enum role: { system_admin: 0, user: 1, gord_top_manager: 2, gord_manager: 3 }

  has_many :owned_projects, class_name: 'Project', inverse_of: :owner
  has_many :documents
  has_many :scheme_mix_criteria_documents
  has_many :projects_users, dependent: :delete_all
  has_many :projects, through: :projects_users
  has_many :requirement_data, dependent: :nullify
  has_many :scheme_mix_criteria, inverse_of: :certifier, foreign_key: 'certifier_id'
  has_many :tasks, dependent: :destroy

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
    projects_users.each do |projects_user|
      if projects_user.project == project && projects_user.certifier_manager?
        return true
      end
    end
    return false
  end

  def project_manager?(project)
    projects_users.each do |projects_user|
      if projects_user.project == project && projects_user.project_manager?
        return true
      end
    end
    return false
  end

  def enterprise_account?(project)
    projects_users.each do |projects_user|
      if projects_user.project == project && projects_user.enterprise_account?
        return true
      end
    end
    return false
  end

  def project_team_member?(project)
    projects_users.each do |projects_user|
      if projects_user.project == project && projects_user.project_team_member?
        return true
      end
    end
    return false
  end

  def certifier?(project)
    projects_users.each do |projects_user|
      if projects_user.project == project && projects_user.certifier?
        return true
      end
    end
    return false
  end

  before_validation :assign_default_role, on: :create

  validates :role, inclusion: User.roles.keys

  private
  def assign_default_role
    self.role = :user if self.role.nil?
  end

end
