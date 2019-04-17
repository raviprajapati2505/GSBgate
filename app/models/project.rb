require 'file_size_validator'

class Project < ApplicationRecord
  include Auditable
  include Taskable
  include DatePlucker

  MAXIMUM_DOCUMENT_FILE_SIZE = 25 # in MB

  has_many :projects_users, dependent: :destroy
  has_many :certification_paths, dependent: :destroy
  has_many :certificates, through: :certification_paths
  has_many :certification_path_statuses, through: :certification_paths
  has_many :notification_types_users, dependent: :destroy
  has_many :project_audit_logs, class_name: 'AuditLog', foreign_key: 'project_id', dependent: :destroy
  belongs_to :building_type_group, optional: true
  belongs_to :building_type, optional: true

  validates :name, presence: true
  validates :owner, presence: true
  validates :address, presence: true
  validates :location, presence: true
  validates :country, presence: true
  validates :location_plan_file, presence: true
  validates :site_plan_file, presence: true
  validates :design_brief_file, presence: true
  validates :project_narrative_file, presence: true
  validates :building_type_id, presence: true
  validates :building_type_group_id, presence: true
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
  validates :certificate_type, inclusion: Certificate.certificate_types.values

  after_initialize :init
  after_create :send_project_registered_email

  mount_uploader :location_plan_file, GeneralSubmittalUploader
  mount_uploader :site_plan_file, GeneralSubmittalUploader
  mount_uploader :design_brief_file, GeneralSubmittalUploader
  mount_uploader :project_narrative_file, GeneralSubmittalUploader

  scope :for_user, ->(user) {
    joins(:projects_users).where(projects_users: {user_id: user.id})
  }

  scope :without_certification_paths, -> {
    includes(:certification_paths).where(certification_paths: {id: nil})
  }

  def completed_letter_of_conformances
    CertificationPath.with_project(self).with_status(CertificationPathStatus::STATUSES_COMPLETED).with_certification_type(Certificate.certification_types[:letter_of_conformance])
  end

  def completed_construction_stage1
    CertificationPath.with_project(self).with_status(CertificationPathStatus::STATUSES_COMPLETED).with_certification_type(Certificate.certification_types[:construction_certificate_stage1])
  end

  def completed_construction_stage2
    CertificationPath.with_project(self).with_status(CertificationPathStatus::STATUSES_COMPLETED).with_certification_type(Certificate.certification_types[:construction_certificate_stage2])
  end

  def completed_construction_stage3
    CertificationPath.with_project(self).with_status(CertificationPathStatus::STATUSES_COMPLETED).with_certification_type(Certificate.certification_types[:construction_certificate_stage3])
  end

  def average_scores_all_construction_stages
    certification_paths = CertificationPath.with_project(self).with_status(CertificationPathStatus::STATUSES_COMPLETED).with_certificate_type(Certificate.certificate_types[:construction_type])
    unless certification_paths.count < 3
      average_scores = {targeted_score: 0, submitted_score: 0, achieved_score: 0}
      certification_paths.each do |certification_path|
        scores = certification_path.scores_in_certificate_points
        average_scores[:targeted_score] += scores[:targeted_score_in_certificate_points]
        average_scores[:submitted_score] += scores[:submitted_score_in_certificate_points]
        average_scores[:achieved_score] += scores[:achieved_score_in_certificate_points]
      end
      average_scores[:targeted_score] /= 3
      average_scores[:submitted_score] /= 3
      average_scores[:achieved_score] /= 3
      return average_scores
    end
  end

  def are_all_construction_stages_certified?
    count = CertificationPath.with_project(self)
              .with_status(CertificationPathStatus::CERTIFIED)
              .with_certificate_type(Certificate.certificate_types[:construction_type])
              .count
    if count == 3
      return true
    end
    return false
  end

  def role_for_user(user)
    projects_users.each do |projects_user|
      if projects_user.user == user
        return projects_user.role
      end
    end
    return false
  end

  def certification_manager_assigned?
    projects_users.each do |projects_user|
      if projects_user.certification_manager?
        return true
      end
    end
    return false
  end

  def has_active_certificate?
    certification_paths.each do |certification_path|
      return true if (certification_path.is_completed? == false)
    end
    return false
  end

  # returns the most important scheme mix which is
  # either the main scheme mix for the oldest certification path (should be the same as following certification paths)
  # or the scheme mix of the oldest certification path with the highest weight
  def most_important_scheme_mix
    oldest_cert_path = certification_paths.sort_by {|cat| cat.created_at}.first
    unless oldest_cert_path.nil?
      # return main scheme_mix
      return oldest_cert_path.main_scheme_mix unless oldest_cert_path.main_scheme_mix.nil?
      # return heaviest scheme_mix
      return oldest_cert_path.scheme_mixes.max_by {|sm| sm.weight}
    end
    return nil
  end

  # returns a hash with key = category code; value = achieved score in certificate points (sum for all scheme mixes)
  def categories
    categories = {}
    certification_paths.each do |cp|
      cp.scheme_mixes.each do |sm|
        scheme_mix_criteria_scores_by_category = sm.scheme_mix_criteria_scores.group_by{|item| item[:scheme_category_id]}
        unless scheme_mix_criteria_scores_by_category.nil?
          sm.scheme_categories.each do |c|
            categories[c.code] = 0 if categories[c.code].nil?
            categories[c.code] += scheme_mix_criteria_scores_by_category[c.id].sum {|score| score[:achieved_score_in_certificate_points].nil? ? 0 : score[:achieved_score_in_certificate_points]} unless scheme_mix_criteria_scores_by_category[c.id].nil?
          end
        end
      end
    end
    return categories
  end

  # def can_create_certification_path_for_certification_type?(certification_type)
  #   # There should be only one certification path per certificate
  #   # TODO: this may be a bad assumption, perhaps extend logic to also look at the status (e.g an older rejected certification_path may be allowed)
  #   return false if CertificationPath.joins(:certificate).exists?(project: self, certificates: {certification_type: certification_type})
  #   # No dependencies for Operations certificate
  #   return true if certification_type == Certificate.certification_types[:operations_certificate]
  #   # No dependencies for LOC certificate
  #   return true if certification_type == Certificate.certification_types[:letter_of_conformance]
  #   # No dependencies for Construction certificate
  #   return true if certification_type == Certificate.certification_types[:construction_certificate]
  #   # FinalDesign needs a LOC
  #   return true if certification_type == Certificate.certification_types[:final_design_certificate] && CertificationPath.joins(:certificate).exists?(project: self, certificates: {certification_type:  Certificate.certification_types[:letter_of_conformance]})
  #   # default to false
  #   return false
  # end

  private
  def init
    if self.has_attribute?('code')
      # Set default code
      self.code ||= 'TBC'
    end

    if self.has_attribute?('coordinates')
      # Set default lat/lng location to Doha, Qatar
      self.coordinates ||= '25.2916097,51.53043679999996'
    end
  end

  def send_project_registered_email
    DigestMailer.project_registered_email(self).deliver_now
  end
end
