class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  attr_accessor :skip_send_user_licences_update_email
  include Taskable

  devise  :invitable, :database_authenticatable, :registerable, :recoverable,
          :rememberable, :trackable, :validatable, :confirmable

  include ActionView::Helpers::TranslationHelper
  include DatePlucker

  enum role: { system_admin: 5, default_role: 1, gsb_top_manager: 2, gsb_manager: 3, gsb_admin: 4, document_controller: 6, record_checker: 7, users_admin: 8, corporate: 9, credentials_admin: 10, certification_manager: 11 }, _prefix: :is

  enum practitioner_accreditation_type: { licentiate: 1, advocate: 2, fellow: 3, associate: 4 }

  belongs_to :corporate, class_name: 'Corporate', foreign_key: 'corporate_id', optional: true
  has_one :user_detail, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :scheme_mix_criteria_documents
  has_many :projects_users, dependent: :destroy
  has_many :projects, through: :projects_users
  has_many :requirement_data, dependent: :nullify
  has_many :scheme_mix_criteria, inverse_of: :certifier, foreign_key: 'certifier_id', dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :audit_logs, dependent: :destroy
  has_many :notification_types_users, dependent: :destroy
  has_many :notification_types, through: :notification_types_users
  has_many :archives, dependent: :destroy
  has_many :access_licences, dependent: :destroy
  has_many :licences, through: :access_licences
  has_many :cgp_licences, -> { where(licence_type: 'CgpLicence') }, class_name: 'Licence', through: :access_licences, source: :licence
  has_many :cep_licences, -> { where(licence_type: 'CepLicence') }, class_name: 'Licence', through: :access_licences, source: :licence
  has_many :corporate_licences, -> { where(licence_type: 'CorporateLicence') }, class_name: 'Licence', through: :access_licences, source: :licence
  has_many :demerit_flags, dependent: :destroy

  accepts_nested_attributes_for :access_licences, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :user_detail

  after_initialize :init, if: :new_record?
  before_create :before_create
  after_update :set_approval_date, if: :saved_change_to_active?
  after_save :send_user_licences_update_email

  validates :email, uniqueness: true
  validates :username, uniqueness: true
  validates :role, inclusion: User.roles.keys
  validates :email, :username, :name, :country, :mobile_area_code, :mobile, :organization_name, :organization_address, :organization_email, :organization_country, presence: true, unless: -> { encrypted_password_changed? } 
  validates :organization_phone_area_code, :organization_phone, :organization_fax_area_code, :organization_fax,  numericality: { allow_blank: true }, unless: -> { encrypted_password_changed? } 
  validates_numericality_of :mobile_area_code, :mobile, only_integer: true, unless: -> { encrypted_password_changed? } 
  
  validate :validate_org_webiste
  validate :validate_name_suffix, unless: -> { encrypted_password_changed? } 
  validates :access_licences, :nested_attributes_uniqueness => {field: :licence_id}
  delegate :can?, :cannot?, :to => :ability

  mount_uploader :profile_pic, ProfilePicUploader

  scope :active, -> {
    where(active: true)
  }

  scope :unassigned, -> {
    User.includes(:projects_users).where(projects_users: {id: nil})
  }

  scope :search_email, ->(text) {
    where('email like :search_text', search_text: "%#{text}%")
  }

  scope :local_users, -> {
    where(linkme_user: false)
  }

  scope :confirmed_users, -> {
    where.not(confirmed_at: nil)
  }

  scope :active, -> {
    where(active: true)
  }

  # scope :not_authorized_for_project, ->(project) {
  #   where.not('exists(select id from projects_users where user_id = users.id and project_id = ?)', project.id)
  # }

  # scope :without_permissions_for_project, ->(project) {
  #   where(role: 1) & not_owning_project(project) & not_authorized_for_project(project)
  # }

  scope :authorized_for_project, ->(project, certification_path) {
    joins(:projects_users).where(projects_users: {project_id: project.id, certification_team_type: certification_path&.projects_users_certification_team_type})
  }

  scope :with_project_team_role, -> {
    joins(:projects_users).where(projects_users: {role: [ProjectsUser.roles[:project_team_member], ProjectsUser.roles[:cgp_project_manager]]})
  }

  scope :with_gsb_team_role, -> {
    joins(:projects_users).where(projects_users: {role: [ProjectsUser.roles[:certifier], ProjectsUser.roles[:certification_manager]]})
  }

  scope :with_cgp_project_manager_role_for_project, ->(project, certification_path) {
    joins(:projects_users).where(projects_users: {project_id: project.id, certification_team_type: certification_path&.projects_users_certification_team_type, role: ProjectsUser.roles[:cgp_project_manager]})
  }

  scope :valid_cgps_with_type, -> (certificate_type) {
    self
      .joins("INNER JOIN access_licences on access_licences.user_id = users.id")
      .joins("INNER JOIN licences on licences.id = access_licences.licence_id")
      .where(
        "DATE(access_licences.expiry_date) > :current_date 
        AND licences.licence_type = 'CgpLicence' 
        AND licences.certificate_type = :certificate_type 
        AND users.active = true", 
        current_date: Date.today, 
        certificate_type: certificate_type
      ) 
  }

  scope :valid_ceps_with_type, -> (certificate_type) {
    self
      .joins("INNER JOIN access_licences on access_licences.user_id = users.id")
      .joins("INNER JOIN licences on licences.id = access_licences.licence_id")
      .where(
        "DATE(access_licences.expiry_date) > :current_date 
        AND licences.licence_type = 'CepLicence' 
        AND licences.certificate_type = :certificate_type 
        AND users.active = true", 
        current_date: Date.today, 
        certificate_type: certificate_type
      )
  }

  def full_name
    "#{name_suffix} #{name} #{middle_name} #{last_name}".strip
  end

  def unique_licence
    all_licence_ids = access_licences.pluck(:licence_id)
    
    unless all_licence_ids == all_licence_ids.uniq
      self.errors[:base] << "Licence Duplication Error"
      return false
    end

    return true
  end

  def remaining_licences
    if type == 'Corporate'
      Licence.with_corporate_licences
    else
      Licence.with_cp_licences
    end
  end

  def is_admin?
    ["system_admin", "gsb_top_manager", "gsb_manager", "gsb_admin"].include?(role)
  end
  
  def self.is_corporate(current_user)
    ["corporate"].include?(current_user.role)
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
    @current_ability ||= Ability.new(self)
  end

  def log_sign_in
    self.last_sign_in_at = Time.now.utc
    self.sign_in_count ||= 0
    self.sign_in_count += 1
  end

  def jwt_subject
    id
  end

  def jwt_payload
    {
      username: username
    }
  end

  def has_role?(role = [])
    role.include?(self.role) rescue false
  end

  def corporate_name
    corporate&.name
  end

  def access_licences_with_certificate_type(certificate_type)
    access_licences.with_certificate_type(certificate_type.to_i) || AccessLicence.none
  end

  # ------------------- methods for corporates --------------------------- 
  def valid_user_sp_licences
    corporate&.active? ? corporate&.valid_corporate_licences : AccessLicence.none
  end
  
  # Define a generic method for all corporate license checks dynamically
  Certificate::CERTIFICATE_TYPES.each do |type|
    define_method("valid_user_sp_#{type}_licence") do
      corporate&.active? ? corporate&.send("valid_corporate_#{type}_licences") : AccessLicence.none
    end
  end

  # ------------------- methods for CGPs and CEPs --------------------------- 

  def valid_cgp_or_cep_available?
    corporate&.active? && (corporate&.valid_cgps.present? || corporate&.valid_ceps.present?)
  end

  # Define a generic method for all CGP and CEP license checks dynamically
  Certificate::CERTIFICATE_TYPES.each do |cert_type|
    define_method("valid_#{cert_type}_cp_available?") do
      corporate&.active? && (
        corporate&.send("valid_#{cert_type}_cgps")&.present? ||
        corporate&.send("valid_#{cert_type}_ceps")&.present?
      )
    end
  end
  # ------------------- methods for user licences --------------------------- 

  def valid_user_licences
    access_licences
      .joins(:licence)
      .where(
        "DATE(access_licences.expiry_date) > :current_date 
        AND licences.licence_type IN ('CgpLicence', 'CepLicence', 'CorporateLicence')", 
        current_date: Date.today
      ) || AccessLicence.none
  end

  # Define a generic method for all user license checks dynamically
  Certificate::CERTIFICATE_TYPES.each do |cert_type|
    define_method("valid_user_#{cert_type}_licences") do
      valid_user_licences
        .where("licences.certificate_type = ?", Certificate.certificate_types[:"#{cert_type}_type"]) || AccessLicence.none
    end
  end

  # ------------------- methods for user licences --------------------------- 

  def user_with_licences(licence_ids = [])
    access_licences.joins(:licence).where(licence_id: licence_ids)
  end

  def valid_checklist_licences
    licence_ids =  Licence.where(
                                  applicability: [ Licence.applicabilities[:check_list] ], 
                                  licence_type: ["CgpLicence", "CepLicence", "CorporateLicence"]
                                ).ids

    valid_user_licences.where(licence_id: licence_ids)
  end

  # Filter schemes which is only for assessment method
  def manage_assessment_methods_options
    assessment_methods = CertificationPath.assessment_methods

    return assessment_methods
  end

  def allowed_certification_types
    return Certificate.certificate_types if is_system_admin?

    sp_allowed_certificate_types = valid_user_sp_licences&.pluck(:certificate_type)&.uniq || []
    cp_allowed_certificate_types = valid_user_licences&.pluck(:certificate_type)&.uniq || []

    sp_cp_allowed_certificate_types = sp_allowed_certificate_types & cp_allowed_certificate_types
    
    # for checklist licences, corporate licences verification not needed.
    valid_checklist_licences_certificate_type = valid_checklist_licences.pluck("licences.certificate_type")
    # allowed_certificate_types = Certificate.certificate_types.select { |k, v| (sp_cp_allowed_certificate_types.uniq).include?(v) }

    certificate_types = {}
    # allowed_certificate_types.each do |k, v|
    #   certificate_types[k] = v if send("valid_#{k.gsub('_type', '')}_cp_available?")
    # end

    if valid_checklist_licences_certificate_type.present?
      valid_checklist_licences_certificate_type.each do |certificate_type|
        certificate_types.merge!(Hash[*Certificate.certificate_types.to_a[certificate_type]])
      end
    end

    return certificate_types
  end

  def generate_jwt
    JWT.encode({ id: id, exp: 10.minute.from_now.to_i }, Rails.application.config.devise_jwt_secret_key)
  end

  private

  def init
    self.role ||= :default_role
    if self.gord_employee.nil?
      self.gord_employee = false
    end
  end

  def before_create
    self.last_notified_at = Time.current
  end

  def send_user_licences_update_email
    return if skip_send_user_licences_update_email || !access_licences.any?(&:saved_changes?) # we dont need to send licence emails if user is imported through seed
    DigestMailer.user_licences_update_email(self).deliver_now
  end

  def set_approval_date
    value = active? ? Time.now : nil
    self.update_column(:approved_at, value)
  end

  def validate_org_webiste
    return if organization_website.present? && URI.regexp.match(organization_website)
  
    errors.add(:organization_website, 'Please enter a valid website url')
  end

  def validate_name_suffix
    if !name_suffix.present? && (self.role == 'default_role' || self.role == 'corporate')
      errors.add(:name_suffix, 'cant be blank')
    end
  end
end
