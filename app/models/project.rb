require 'file_size_validator'

class Project < ActiveRecord::Base
  include Auditable
  include Taskable

  MAXIMUM_DOCUMENT_FILE_SIZE = 25 # in MB

  belongs_to :owner, class_name: 'User', inverse_of: :owned_projects
  has_many :projects_users, dependent: :destroy
  has_many :certification_paths, dependent: :destroy
  has_many :notification_types_users, dependent: :destroy
  has_many :project_audit_logs, class_name: 'AuditLog', foreign_key: 'project_id', dependent: :destroy

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
  validates :location_plan_file, file_size: {maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }
  validates :site_plan_file, file_size: {maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }
  validates :design_brief_file, file_size: {maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }
  validates :project_narrative_file, file_size: {maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }

  after_initialize :init

  mount_uploader :location_plan_file, GeneralSubmittalUploader
  mount_uploader :site_plan_file, GeneralSubmittalUploader
  mount_uploader :design_brief_file, GeneralSubmittalUploader
  mount_uploader :project_narrative_file, GeneralSubmittalUploader

  default_scope { order(name: :asc) }

  scope :for_owner, ->(user) {
    where(owner: user)
  }

  scope :for_user, ->(user) {
    joins(:projects_users).where(projects_users: {user_id: user.id})
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

  def can_create_certification_path_for_certificate?(certificate)
    # There should be only one certification path per certificate
    # TODO: this may be a bad assumption, perhaps extend logic to also look at the status (e.g an older rejected certification_path may be allowed)
    return false if certification_paths.exists?(certificate: certificate)
    # No dependencies for Operations certificate
    return true if certificate.operations_certificate?
    # No dependencies for LOC certificate
    return true if certificate.letter_of_conformance?
    # No dependencies for Construction certificate
    return true if certificate.construction_certificate?
    # FinalDesign needs a LOC
    return true if certificate.final_design_certificate? && certification_paths.exists?(certificate: Certificate.letter_of_conformance)
    # default to false
    return false
  end

  def init
    if self.has_attribute?('code')
      # Set default code
      self.code ||= 'TBC'
    end

    if self.has_attribute?('latlng')
      # Set default latlng location to Doha, Qatar
      self.latlng ||= 'POINT(51.53043679999996 25.2916097)'
    end
  end
end
