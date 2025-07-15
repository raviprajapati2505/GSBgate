require 'file_size_validator'

class Project < ApplicationRecord
  include Auditable
  include Taskable
  include DatePlucker

  enum project_owner_business_sector: { individual: 1, corporate: 2, government: 3 }
  enum project_developer_business_sector: { individual: 1, corporate: 2, government: 3 }, _prefix: :developer

  MAXIMUM_DOCUMENT_FILE_SIZE = 25 # in MB

  has_many :projects_users, dependent: :destroy
  has_many :projects_surveys, dependent: :destroy
  has_many :certification_paths, dependent: :destroy
  has_many :certificates, through: :certification_paths
  has_many :certification_path_statuses, through: :certification_paths
  has_many :notification_types_users, dependent: :destroy
  has_many :project_audit_logs, class_name: 'AuditLog', foreign_key: 'project_id', dependent: :destroy
  has_many :actual_project_images, dependent: :destroy
  has_many :project_rendering_images, dependent: :destroy
  belongs_to :building_type_group, optional: true
  belongs_to :building_type, optional: true

  validates :name, presence: true
  validates :certificate_type, presence: true
  validates :owner, presence: true
  validates :developer, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :district, presence: true
  validates :country, presence: true
  validates :construction_year, presence: true
  validates :location_plan_file, presence: true
  validates :site_plan_file, presence: true
  validates :sustainability_features_file, presence: true
  validates :design_brief_file, presence: true
  # validates :building_type_id, presence: true
  # validates :building_type_group_id, presence: true
  validates :gross_area, numericality: { greater_than_or_equal_to: 0 }
  validates :certified_area, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :carpark_area, numericality: { greater_than_or_equal_to: 0 }
  validates :project_site_area, numericality: { greater_than_or_equal_to: 0 }
  validates :buildings_footprint_area, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :construction_year, numericality: { only_integer: true, greater_than: 0 }
  validates :terms_and_conditions_accepted, acceptance: true
  validates :location_plan_file, file_size: {maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }
  validates :site_plan_file, file_size: {maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }
  validates :design_brief_file, file_size: {maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }
  validates :sustainability_features_file, file_size: {maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }
  validates :area_statement_file, file_size: {maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }
  validates :project_narrative_file, file_size: {maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }
  validates :certificate_type, inclusion: Certificate.certificate_types.values
  validate :presence_of_files

  after_initialize :init
  after_create :send_project_registered_email
  after_update :change_projects_users_certification_team_type, if: :saved_change_to_certificate_type?

  mount_uploader :location_plan_file, GeneralSubmittalUploader
  mount_uploader :site_plan_file, GeneralSubmittalUploader
  mount_uploader :design_brief_file, GeneralSubmittalUploader
  mount_uploader :project_narrative_file, GeneralSubmittalUploader
  mount_uploader :sustainability_features_file, GeneralSubmittalUploader
  mount_uploader :area_statement_file, GeneralSubmittalUploader

  scope :for_user, ->(user) {
    joins(:projects_users).where(projects_users: {user_id: user.id})
  }

  scope :total_completed_project_by_role, ->(user, project_role, project_stage) {
    joins(:projects_users).where(projects_users: {user_id: user.id, role: project_role}).includes(:certification_paths).where(certification_paths: {certification_path_status_id: project_stage}).map(&:id).uniq
  }

  scope :total_inprogress_project_by_role, ->(user, project_role, project_stage) {
    joins(:projects_users).where(projects_users: {user_id: user.id, role: project_role}).includes(:certification_paths).where.not(certification_paths: {certification_path_status_id: project_stage}).map(&:id).uniq
  }

  scope :without_certification_paths, -> {
    includes(:certification_paths).where(certification_paths: {id: nil})
  }

  def self.datatable_projects_records
    all_projects = 
      self
        .joins('LEFT OUTER JOIN projects_users ON projects_users.project_id = projects.id')
        .joins('LEFT OUTER JOIN certification_paths ON certification_paths.project_id = projects.id')
        .joins('LEFT JOIN certificates ON certification_paths.certificate_id = certificates.id')
        .joins('LEFT JOIN certification_path_statuses ON certification_paths.certification_path_status_id = certification_path_statuses.id')
        .joins('LEFT JOIN development_types ON certification_paths.development_type_id = development_types.id')
        .joins('LEFT JOIN building_types ON projects.building_type_id = building_types.id')
        .group('projects.id')
        .group('projects.owner')
        .group('projects.developer')
        .group('certification_paths.id')
        .group('certificates.id')
        .group('certification_path_statuses.id')
        .group('development_types.id')
        .group('building_types.id')
        .select('projects.id AS project_nr')
        .select('projects.code AS project_code')
        .select('projects.name AS project_name')
        .select('projects.construction_year AS project_construction_year')
        .select('projects.project_owner_business_sector AS project_owner_business_sector')
        .select('projects.country AS project_country')
        .select('projects.city AS project_city')
        .select('projects.district AS project_district')
        .select('projects.project_developer_business_sector AS project_developer_business_sector')
        .select('projects.description AS project_description')
        .select('projects.gross_area AS project_gross_area')
        .select('projects.certified_area AS project_certified_area')
        .select('projects.carpark_area AS project_carpark_area')
        .select('projects.project_site_area AS project_site_area')
        .select('projects.buildings_footprint_area AS project_buildings_footprint_area')
        .select('projects.owner AS project_owner')
        .select('projects.developer AS project_developer')
        .select('projects.corporate AS project_corporate')
        .select('certification_paths.id AS certification_path_id')
        .select('certification_paths.updated_at AS certification_path_updated_at')
        .select('certification_paths.certificate_id AS certificate_id')
        .select('certification_paths.certification_path_status_id AS certification_path_certification_path_status_id')
        .select('certification_paths.pcr_track AS certification_path_pcr_track')
        .select("ARRAY_TO_STRING(ARRAY(SELECT schemes.name FROM schemes INNER JOIN scheme_mixes ON schemes.id = scheme_mixes.scheme_id WHERE scheme_mixes.certification_path_id = certification_paths.id), '|||') AS certification_scheme_name")
        .select('development_types.name AS development_type_name')
        .select('building_types.name AS building_type_name')
        .select('certification_paths.started_at AS certification_path_started_at')
        .select('certification_paths.certified_at AS certification_path_certified_at')
        .select('certification_paths.expires_at AS certification_path_expires_at')
        .select("certificates.name AS certificate_name")
        .select("certificates.certificate_type AS certificate_type")
        .select('certificates.gsb_version AS certificate_gsb_version')
        .select('certification_path_statuses.name AS certification_path_status_name')
        .select('CASE WHEN certification_path_statuses.id IS NULL THEN false WHEN certification_path_statuses.id = 15 THEN false WHEN certification_path_statuses.id = 16 THEN false WHEN certification_path_statuses.id = 17 THEN false ELSE true END AS certification_path_status_is_active')
        .select("ARRAY_TO_STRING(ARRAY(SELECT case when scheme_mixes.custom_name is null then schemes.name else schemes.name end from schemes INNER JOIN scheme_mixes ON schemes.id = scheme_mixes.scheme_id WHERE scheme_mixes.certification_path_id = certification_paths.id), '|||') AS schemes_array")
        .select("ARRAY_TO_STRING(ARRAY(SELECT case when scheme_mixes.custom_name is null then ' ' else scheme_mixes.custom_name end from schemes INNER JOIN scheme_mixes ON schemes.id = scheme_mixes.scheme_id WHERE scheme_mixes.certification_path_id = certification_paths.id ORDER BY schemes.name), '|||') AS schemes_custom_name_array")
        .select('(%s) AS project_team_array' % ApplicationController.helpers.projects_users_by_type('project_team'))
        .select('(%s) AS cgp_project_manager_array' % ApplicationController.helpers.projects_users_by_type('cgp_project_manager'))
        .select('(%s) AS gsb_team_array' % ApplicationController.helpers.projects_users_by_type('gsb_team'))
        .select('(%s) AS certification_manager_array' % ApplicationController.helpers.projects_users_by_type('certification_manager'))
        .select('(%s) AS enterprise_clients_array' % ApplicationController.helpers.projects_users_by_type('enterprise_clients'))
        .select('(%s) AS total_achieved_score' % Effective::Datatables::ProjectsCertificationPaths.query_score_in_certificate_points(:targeted_score))

        return all_projects
  end

  def presence_of_files
    unless (project_narrative_file.present? || area_statement_file.present?)
      errors.add(:area_statement_file, "can't be blank.")
    end
  end

  def completed_provisional_certificate
    completed_provisional_energy_centers_efficiency.first ||
    completed_provisional_measurement_reporting_and_verification.first ||
    completed_provisional_building_water_efficiency.first ||
    completed_provisional_events_carbon_neutrality.first ||
    completed_provisional_products_ecolabeling.first ||
    completed_provisional_green_IT.first ||
    completed_provisional_net_zero_energy.first ||
    completed_provisional_energy_label_for_building_performance.first ||
    completed_provisional_indoor_air_quality_certification.first ||
    completed_provisional_indoor_environmental_quality_certification.first ||
    completed_provisional_energy_label_for_wastewater_treatment_plant.first ||
    completed_provisional_energy_label_for_leachate_treatment_plant.first ||
    completed_provisional_healthy_building_label.first ||
    completed_provisional_energy_label_for_industrial_application.first ||
    completed_provisional_energy_label_for_infrastructure_projects.first ||
    CertificationPath.none
  end

  Certificate::CERTIFICATE_TYPES.each do |cert_type|
    define_method("completed_provisional_#{cert_type}") do
      CertificationPath.with_project(self).with_status(CertificationPathStatus::STATUSES_COMPLETED).with_certification_type(Certificate.certification_types[:"provisional_#{cert_type}"])
    end
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

  def can_upload_project_rendering_image?
    true
  end

  def can_upload_actual_image?
    completed_provisional_certificate.present?
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
            categories[c.code] = {} if categories[c.code].nil?
            categories[c.code]['achieved_score'] = 0 if categories[c.code]['achieved_score'].nil?
            categories[c.code]['achieved_score'] += scheme_mix_criteria_scores_by_category[c.id].sum {|score| score[:achieved_score_in_certificate_points].nil? ? 0 : score[:achieved_score_in_certificate_points]} unless scheme_mix_criteria_scores_by_category[c.id].nil?


            scheme_mix_criterion = sm.scheme_mix_criteria.for_category(c).first
            categories[c.code]['EPL_band'] = scheme_mix_criterion.scheme_mix_criterion_epls.map {|epl| {label: epl.scheme_criterion_performance_label.label, band: epl.band}} if c.code == 'E'
            categories[c.code]['WPL_band'] = scheme_mix_criterion.scheme_mix_criterion_wpls.map {|wpl| {label: wpl.scheme_criterion_performance_label.label, band: wpl.band}} if c.code == 'W'
          end
        end
      end
    end
    return categories
  end

  Certificate::CERTIFICATE_TYPES.each do |cert_type|
    define_method("#{cert_type}?") do
      certificate_type == Certificate.certificate_types[:"#{cert_type}_type"]
    end
  end

  def team_table_heading
    case certificate_type
      when 0
        I18n.t('activerecord.attributes.project.team_titles.energy_centers_efficiency')
      when 1
        I18n.t('activerecord.attributes.project.team_titles.measurement_reporting_and_verification')
      when 2
        I18n.t('activerecord.attributes.project.team_titles.building_water_efficiency')
      when 3
        I18n.t('activerecord.attributes.project.team_titles.events_carbon_neutrality')
      when 4
        I18n.t('activerecord.attributes.project.team_titles.products_ecolabeling')
      when 5
        I18n.t('activerecord.attributes.project.team_titles.green_IT')
      when 6
        I18n.t('activerecord.attributes.project.team_titles.net_zero_energy')
      when 7
        I18n.t('activerecord.attributes.project.team_titles.energy_label_for_building_performance')
      when 8
        I18n.t('activerecord.attributes.project.team_titles.indoor_air_quality_certification')
      when 9
        I18n.t('activerecord.attributes.project.team_titles.indoor_environmental_quality_certification')
      when 10
        I18n.t('activerecord.attributes.project.team_titles.energy_label_for_wastewater_treatment_plant')
      when 11
        I18n.t('activerecord.attributes.project.team_titles.energy_label_for_leachate_treatment_plant')
      when 12
        I18n.t('activerecord.attributes.project.team_titles.healthy_building_label')
      when 13
        I18n.t('activerecord.attributes.project.team_titles.energy_label_for_industrial_application')
      when 14
        I18n.t('activerecord.attributes.project.team_titles.energy_label_for_infrastructure_projects')
      else
        "Project Team"
    end
  end

  def check_documents_permissions
    begin
      if certification_paths.present?
        recent_certification_path = certification_paths.joins(:certificate).order("certificates.display_weight").last
        recent_certificate_type = recent_certification_path&.certificate&.certification_type
        recent_certificate_status = recent_certification_path&.certification_path_status_id

        return !(
                  Certificate::FINAL_CERTIFICATES
                    .include?(recent_certificate_type&.to_sym) && 
               [
                CertificationPathStatus::CERTIFIED, 
                CertificationPathStatus::NOT_CERTIFIED
               ].include?(recent_certificate_status))
      else
        true
      end

    rescue StandardError => exception
      puts exception.message
      return false
    end
  end

  def is_project_certified?
    begin
      if certification_paths.present?
        recent_certification_path = certification_paths.joins(:certificate).order("certificates.display_weight").last
        recent_certificate_type = recent_certification_path&.certificate&.certification_type
        recent_certificate_status = recent_certification_path&.certification_path_status_id
        return (
                  Certificate::FINAL_CERTIFICATES
                    .include?(recent_certificate_type&.to_sym) && 
               [
                CertificationPathStatus::CERTIFIED
               ].include?(recent_certificate_status))
      else
        false
      end

    rescue StandardError => exception
      puts exception.message
      return false
    end
  end

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

  def change_projects_users_certification_team_type
    certificate_team_type = :other
    projects_users&.update_all(certification_team_type: certificate_team_type)
  end

end
