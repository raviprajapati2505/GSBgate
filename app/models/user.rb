require 'bcrypt'

class User < ActiveRecord::Base
  include BCrypt

  enum role: { system_admin: 0, user: 1, gord_top_manager: 2, gord_manager: 3, gord_admin: 4, assessor: 5, certifier: 6, enterprise_client: 7 }

  has_many :documents
  has_many :scheme_mix_criteria_documents
  has_many :projects_users, dependent: :destroy
  has_many :projects, through: :projects_users
  has_many :requirement_data, dependent: :nullify
  has_many :scheme_mix_criteria, inverse_of: :certifier, foreign_key: 'certifier_id'
  has_many :tasks, dependent: :destroy
  has_many :audit_logs
  has_many :notification_types_users, dependent: :destroy
  has_many :notification_types, through: :notification_types_users

  after_initialize :init, if: :new_record?

  validates :role, inclusion: User.roles.keys

  default_scope { order(username: :asc) }

  delegate :can?, :cannot?, :to => :ability

  scope :unassigned, -> {
    User.includes(:projects_users).where(projects_users: {id: nil})
  }

  scope :assessors, -> {
    where(role: User.roles[:assessor])
  }

  scope :certifiers, -> {
    where(role: User.roles[:certifier])
  }

  scope :enterprise_clients, -> {
    where(role: User.roles[:enterprise_client])
  }

  scope :search_email, ->(text) {
    where('email like :search_text', search_text: "%#{text}%")
  }

  scope :linkme_users, -> {
    where(linkme_user: true)
  }

  scope :local_users, -> {
    where(linkme_user: false)
  }
  
  # scope :not_authorized_for_project, ->(project) {
  #   where.not('exists(select id from projects_users where user_id = users.id and project_id = ?)', project.id)
  # }

  # scope :without_permissions_for_project, ->(project) {
  #   where(role: 1) & not_owning_project(project) & not_authorized_for_project(project)
  # }

  scope :authorized_for_project, ->(project) {
    joins(:projects_users).where(projects_users: {project_id: project.id})
  }

  scope :with_assessor_project_role, -> {
    where('projects_users.role in (0, 1)')
  }

  scope :with_certifier_project_role, -> {
    where('projects_users.role in (3, 4)')
  }

  def password
    @password ||= Password.new(self.encrypted_password)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.encrypted_password = @password
  end

  # Store the user in the current Thread (needed for our concerns, so they can access the current user model)
  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  def self.safe_roles
    User.roles.except(:system_admin, :user)
  end

  # Returns the humanized role of the user in a project.
  # Returns the humanized system role of the user if the user isn't linked to the project.
  def humanized_project_role(project)
    project_user = ProjectsUser.find_by(project: project, user: self)
    return project_user.present? ? I18n.t(project_user.role, scope: 'activerecord.attributes.projects_user.roles') : I18n.t(self.role, scope: 'activerecord.attributes.user.roles')
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def log_sign_in
    self.last_sign_in_at = Time.now.utc
    self.sign_in_count ||= 0
    self.sign_in_count += 1
  end

  private
  def init
    self.role ||= :assessor
    self.linkme_user ||= :true
  end

end
