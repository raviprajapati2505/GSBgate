require 'bcrypt'

class User < ApplicationRecord
  include ActionView::Helpers::TranslationHelper
  include BCrypt
  include DatePlucker

  enum role: { system_admin: 5, default_role: 1, gsas_trust_top_manager: 2, gsas_trust_manager: 3, gsas_trust_admin: 4,document_controller: 6, record_checker: 7 }

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
  has_many :archives

  after_initialize :init, if: :new_record?
  before_create :before_create

  validates :role, inclusion: User.roles.keys

  delegate :can?, :cannot?, :to => :ability

  scope :unassigned, -> {
    User.includes(:projects_users).where(projects_users: {id: nil})
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

  scope :with_project_team_role, -> {
    joins(:projects_users).where(projects_users: {role: [ProjectsUser.roles[:project_team_member], ProjectsUser.roles[:cgp_project_manager]]})
  }

  scope :with_gsas_trust_team_role, -> {
    joins(:projects_users).where(projects_users: {role: [ProjectsUser.roles[:certifier], ProjectsUser.roles[:certification_manager]]})
  }

  scope :with_cgp_project_manager_role_for_project, ->(project) {
    joins(:projects_users).where(projects_users: {project_id: project.id, role: ProjectsUser.roles[:cgp_project_manager]})
  }

  def full_name
    name
  end

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
    return project_user.present? ? t(project_user.role, scope: 'activerecord.attributes.projects_user.roles') : t(self.role, scope: 'activerecord.attributes.user.roles')
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def log_sign_in
    self.last_sign_in_at = Time.now.utc
    self.sign_in_count ||= 0
    self.sign_in_count += 1
  end


  # Updates or creates a linkme user in the DB.
  # - member_profile: A linkme member profile hash returned by the LinkmeService
  # - master_profile: A linkme member profile hash returned by the LinkmeService which functions as the Service Provider/Employer
  def self.update_or_create_linkme_user!(member_profile = nil, master_profile = nil)
    # Check if the user exists in the GSAS DB
    user = linkme_users.find_by_linkme_member_id(member_profile[:id]&.upcase)

    # If the user record doesn't exist, create it
    user ||= new

    # Update the user's data
    user.linkme_user = true
    user.linkme_member_id = member_profile[:id]&.upcase
    user.username = member_profile[:username]
    user.email = member_profile[:email]
    user.picture = member_profile[:picture]
    user.gord_employee = (member_profile[:employer] == 'GORD')
    user.cgp_license = ['GSAS-CGP Licentiate', 'GSAS-CGP Practitioner', 'GSAS-CGP Fellow', 'GSAS-CGP Associate'].include?(member_profile[:membership])
    user.employer_name = member_profile[:employer]

    # CGP license expiry logic
    # ------------------------
    membership_expiry = (master_profile.nil? || master_profile[:membership_expiry].blank?) ? false : master_profile[:membership_expiry]&.to_datetime
    membership_expiry = membership_expiry < DateTime.now unless !membership_expiry

    # Service Provider membership expired ?
    unless membership_expiry
      membership_expiry = member_profile[:membership_expiry].blank? ? false : member_profile[:membership_expiry]&.to_datetime
      membership_expiry = membership_expiry < DateTime.now unless !membership_expiry
    end
    user.cgp_license_expired = membership_expiry

    # Concat the user's name
    user.name = ''
    name_fields = [member_profile[:name_prefix], member_profile[:first_name], member_profile[:middle_name], member_profile[:last_name], member_profile[:name_suffix]]
    name_fields = name_fields.reject { |n| n.blank? }
    user.name = name_fields.join(' ')
    if user.name.blank?
      user.name = self.username
    end

    # Save the user
    user.save!

    user
  end

  def jwt_subject
    id
  end

  def jwt_payload
    {
      username: username
    }
  end

  private
  def init
    self.role ||= :default_role
    if self.linkme_user.nil?
      self.linkme_user = true
    end
    if self.gord_employee.nil?
      self.gord_employee = false
    end
    if self.cgp_license.nil?
      self.cgp_license = false
    end
  end

  def before_create
    self.last_notified_at = Time.current
  end
end
