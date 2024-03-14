require 'file_size_validator'

class CertificationPath < ApplicationRecord
  include ActionView::Helpers::TranslationHelper
  include Auditable
  include Taskable
  include DatePlucker
  include ScoreCalculator

  MAXIMUM_DOCUMENT_FILE_SIZE = 100 # in MB
  enum assessment_method: [ :check_list ]

  belongs_to :project, optional: true
  belongs_to :certificate, optional: true
  belongs_to :certification_path_status, optional: true
  belongs_to :development_type, optional: true
  belongs_to :main_scheme_mix, class_name: 'SchemeMix', optional: true
  has_many :scheme_mixes, dependent: :destroy
  has_many :schemes, through: :scheme_mixes
  has_many :scheme_mix_criteria, through: :scheme_mixes, autosave: true
  has_many :scheme_criteria, through: :scheme_mix_criteria, autosave: true
  has_many :scheme_mix_criteria_documents, through: :scheme_mix_criteria
  has_many :scheme_mix_criteria_requirement_data, through: :scheme_mix_criteria
  has_many :requirement_data, through: :scheme_mix_criteria_requirement_data
  has_many :certification_path_audit_logs, class_name: 'AuditLog', foreign_key: 'certification_path_id', dependent: :destroy
  has_many :cgp_certification_path_documents, dependent: :destroy
  has_many :certifier_certification_path_documents, dependent: :destroy
  has_many :archives, as: :subject, dependent: :destroy
  has_many :actual_project_images, dependent: :destroy
  has_many :project_rendering_images, dependent: :destroy
  has_one :certification_path_report, dependent: :destroy

  accepts_nested_attributes_for :certificate
  accepts_nested_attributes_for :scheme_mixes

  mount_uploader :signed_certificate_file, SignedCertificateUploader

  # enum development_type: {not_applicable: 0, single_use: 1, mixed_use: 2, mixed_development: 3, mixed_development_in_stages: 4}

  validates :project, presence: true
  validates :certificate, presence: true
  validates :max_review_count, numericality: { greater_than: 0 }
  # validates_inclusion_of :development_type, in: CertificationPath.development_types.keys
  validate :total_weight_is_equal_to_100_percent
  validates :signed_certificate_file, file_size: {maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }

  after_initialize :init
  after_create :send_applied_for_certification_email
  before_update :create_descendant_records
  before_update :advance_scheme_mix_criteria_statuses
  before_update :set_started_at
  before_update :set_certified_at
  after_update :create_cda_users, if: -> { is_design_loc? && certification_path_status_id == CertificationPathStatus::CERTIFIED }  
  after_update :create_certification_path_report, if: -> { certification_path_status_id == CertificationPathStatus::CERTIFIED }  

  scope :not_expired, -> {
    where('expires_at > ?', DateTime.now)
  }

  scope :with_status, ->(statuses) {
    joins(:certification_path_status).where(certification_path_status_id: statuses)
  }

  scope :with_status_not, ->(statuses) {
    joins(:certification_path_status).where.not(certification_path_status_id: statuses)
  }

  scope :with_project, ->(project) {
    where(project: project)
  }

  scope :with_certification_type, ->(certification_type) {
    joins(:certificate).where(certificates: {certification_type: certification_type})
  }

  scope :with_certificate_type, ->(certificate_type) {
    joins(:certificate).where(certificates: {certificate_type: certificate_type})
  }

  scope :most_recent, -> do 
    from(
      <<~SQL 
        (
          SELECT id
            FROM certification_paths JOIN (
              SELECT project_id, MAX(created_at) AS created_at
                FROM certification_paths
                GROUP BY project_id
            ) latest_by_created
            ON certification_paths.created_at = latest_by_created.created_at
            AND certification_paths.project_id = latest_by_created.project_id
        ) certification_paths
      SQL
    )
  end
  
  # scope :letter_of_conformance, -> {
  #   joins(:certificate)
  #       .merge(Certificate.letter_of_conformance)
  # }
  #
  # scope :final_design_certificate, -> {
  #   joins(:certificate)
  #       .merge(Certificate.final_design_certificate)
  # }
  #
  # scope :construction_certificate, -> {
  #   joins(:certificate)
  #       .merge(Certificate.construction_certificate)
  # }
  #
  # scope :operations_certificate, -> {
  #   joins(:certificate)
  #       .merge(Certificate.operations_certificate)
  # }

  def init
    # Set status
    if self.has_attribute?('certification_path_status_id')
      self.certification_path_status_id ||= CertificationPathStatus::ACTIVATING
    end
    if self.has_attribute?('expires_at')
      self.expires_at ||= 1.year.from_now
    end
  end

  def name
    self.certificate.full_name
  end

  def status
    status = self.certification_path_status.name
    if status == "Certificate In Process"
      status =  if self.certification_path_report&.is_released?
                  "Certificate Generated"
                else
                  "Certificate In Process"
                end
    end
    
    return status
  end

  def design_and_build?
    project.design_and_build?
  end

  def construction?
    certificate&.construction?
  end

  def ecoleaf?
    certificate.ecoleaf?
  end

  def certification_manager_assigned?
    projects_users = project&.projects_users
                      

    projects_users.each do |projects_user|
      if projects_user.certification_manager?
        return true
      end
    end
    return false
  end

  def projects_users_certification_team_type
    certification_team_type = ProjectsUser.certification_team_types[:other]

    return certification_team_type
  end

  def assessment_method_title
    I18n.t("activerecord.attributes.certification_path.#{assessment_method}")
  end

  def scheme_names
    development_type_name = development_type&.name

    if ["Neighborhoods", "Mixed Use"].include?(development_type_name)
      development_type_name
    elsif main_scheme_mix_selected?
      main_scheme_mix.name
    else
      scheme_names = scheme_mixes&.joins(:scheme).pluck("schemes.name")
      scheme_names&.join(', ')
    end    
  end

  def status_history
    audit_logs = self.audit_logs.where('new_status IS NOT NULL')
    status_history = []
    audit_logs.each do |audit_log|
      status_history << {date: audit_log.created_at, certification_path_status: CertificationPathStatus.find_by_id(audit_log.new_status)}
    end
    status_history
  end

  def main_scheme
    scheme_mixes&.where(id: main_scheme_mix_id)
  end

  def sub_schemes
    scheme_mixes&.where.not(id: main_scheme_mix_id)
  end

  def has_fixed_scheme?
    certificate.schemes.count == 1
  end

  def total_weight
    scheme_mixes.collect { |sm| sm.weight }.inject(:+)
  end

  def total_weight_is_equal_to_100_percent
    if total_weight != 100
      errors.add(:scheme_mixes, 'Scheme weights should total 100%.')
    end
  end

  # Returns the next CertificationPathStatus id in the status flow of the certificate
  def next_status
    case certification_path_status_id
    when CertificationPathStatus::ACTIVATING
      return CertificationPathStatus::SUBMITTING
    when CertificationPathStatus::SUBMITTING
      return CertificationPathStatus::SCREENING
    when CertificationPathStatus::SCREENING
      return CertificationPathStatus::SUBMITTING_AFTER_SCREENING
    when CertificationPathStatus::SUBMITTING_AFTER_SCREENING
      return CertificationPathStatus::VERIFYING
    when CertificationPathStatus::VERIFYING
      return CertificationPathStatus::ACKNOWLEDGING
    when CertificationPathStatus::ACKNOWLEDGING
      if appealed?
        return CertificationPathStatus::PROCESSING_APPEAL_PAYMENT
      elsif has_achieved_score?
        return CertificationPathStatus::APPROVING_BY_MANAGEMENT
      else
        return CertificationPathStatus::NOT_CERTIFIED
      end
    when CertificationPathStatus::PROCESSING_APPEAL_PAYMENT
      return CertificationPathStatus::SUBMITTING_AFTER_APPEAL
    when CertificationPathStatus::SUBMITTING_AFTER_APPEAL
      return CertificationPathStatus::VERIFYING_AFTER_APPEAL
    when CertificationPathStatus::VERIFYING_AFTER_APPEAL
      return CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL
    when CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL
      if has_achieved_score?
        return CertificationPathStatus::APPROVING_BY_MANAGEMENT
      else
        return CertificationPathStatus::NOT_CERTIFIED
      end
    when CertificationPathStatus::APPROVING_BY_MANAGEMENT
      return CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT
    when CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT
      DigestMailer.send_project_certified_email_to_project_owner(self).deliver_now
      return CertificationPathStatus::CERTIFIED
    when CertificationPathStatus::CERTIFIED
      return CertificationPathStatus::CERTIFICATE_IN_PROCESS
    else
      return false
    end
  end

  # add more status names according to requirement.
  ["certified"].each do |status_name|
    define_method "is_next_status_#{status_name}?" do
      next_status == "CertificationPathStatus::#{status_name.upcase}".constantize
    end
  end

  def previous_status
    # only system_admin can use this function
    # TODO provide code for previous_status
    raise NotImplementedError
  end

  def todo_before_status_advance
    todos = []
    todos_schemes = []

    case certification_path_status_id
    when CertificationPathStatus::ACTIVATING
      # TODO certification path expiry date
      unless certification_manager_assigned?
        todos << 'A certification manager must be assigned to the project.'
      end
      if development_type.mixable? && (main_scheme_mix_selected? == false)
        todos << 'A main scheme needs to be selected.'
      end
    when CertificationPathStatus::SCREENING
      scheme_mix_criteria.each do |criterion|
        unless criterion.screened
          todos << 'Some criteria aren\'t screened yet. Please allocate team responsibility for screening or skip screening by marking all criteria as "screened".'
          todos_schemes << criterion&.code
        end
      end
    when CertificationPathStatus::SUBMITTING, CertificationPathStatus::SUBMITTING_AFTER_SCREENING, CertificationPathStatus::SUBMITTING_AFTER_APPEAL
      ['location_plan_file', 'site_plan_file', 'design_brief_file', 'project_narrative_file', 'sustainability_features_file', 'area_statement_file'].each do |general_submittal|
        if project.send(general_submittal).blank?
          if general_submittal == 'sustainability_features_file' 
            if is_project_after_sf_file(project)
              todos << "A '#{Project.human_attribute_name('sustainability_features_file')}' must be added to the project."
            end
          elsif !required_files(project, general_submittal)
            todos << "A '#{Project.human_attribute_name(general_submittal)}' must be added to the project."
          end
        end
      end
      scheme_mix_criteria.each do |criterion|
        if criterion.has_documents_awaiting_approval?
          todos << 'There are still documents awaiting approval.'
          todos_schemes << criterion&.code
        end
        criterion.scheme_mix_criterion_boxes.each do |smcb|
          if smcb.scheme_criterion_box.label == "Targeted Checklist Status" && !smcb.is_checked?
            todos << 'The targeted checklist must be checked.'
            todos_schemes << criterion&.code
            break
          elsif smcb.scheme_criterion_box.label == "Submitted Checklist Status" && !smcb.is_checked?
            todos << 'The submitted checklist must be checked.'
            todos_schemes << criterion&.code
            break
          end
        end
        if criterion.submitting?
          todos << 'Some criteria still have status \'Submitting\'.'
          todos_schemes << criterion&.code
        end
        if criterion.submitting_after_appeal?
          todos << 'Some criteria still have status \'Submitting after appeal\'.'
          todos_schemes << criterion&.code
        end
      end
    when CertificationPathStatus::VERIFYING, CertificationPathStatus::VERIFYING_AFTER_APPEAL
      scheme_mix_criteria.each do |criterion|
        # criterion.scheme_mix_criterion_boxes.each do |smcb|
        #   if smcb.scheme_criterion_box.label == "Achieved Checklist Status" && !smcb.is_checked?
        #     todos << 'The achieved checklist must be checked.'
        #   end
        # end
        if criterion.verifying?
          todos << 'Some criteria still have status \'Verifying\'.'
          todos_schemes << criterion&.code
        end
        if criterion.verifying_after_appeal?
          todos << 'Some criteria still have status \'Verifying after appeal\'.'
          todos_schemes << criterion&.code
        end
      end
    when CertificationPathStatus::CERTIFIED, CertificationPathStatus::NOT_CERTIFIED
      todos << 'This is the final status.'
    end
    return [todos.uniq, todos_schemes.uniq]
  end

  def is_project_after_sf_file(project = nil)
    begin
      "12-04-2022".to_date < project&.created_at&.to_date      
    rescue => exception
      false
    end
  end

  def required_files(project, general_submittal)
    (['project_narrative_file', 'area_statement_file'].include?(general_submittal) && (project.send("project_narrative_file").present? || project.send("area_statement_file").present?))
  end
  
  def allow_certification?(is_achieved_score: true, is_submitted_score: true)
    main_scheme_mixes = self.main_scheme_mix.present? ? self.scheme_mixes.where(id: self.main_scheme_mix.id) : self.scheme_mixes
    main_scheme_mixes.each do |scheme_mix|
      if scheme_mix.scheme.name == 'Healthy Building Mark'
        facility_management_targeted = facility_management_submitted = facility_management_achieved = false
        indoor_environment_targeted = indoor_environment_submitted = indoor_environment_achieved = false
        waste_management_targeted = waste_management_submitted = waste_management_achieved = false
        scheme_mix.scheme_mix_criteria.each do |smc|
          if smc.scheme_criterion.scheme_category.code == 'FM'
            if is_submitted_score 
              facility_management_submitted = is_valid?(smc.submitted_score, 1)
              return facility_management_submitted if !facility_management_submitted
            elsif is_achieved_score
              facility_management_achieved = is_valid?(smc.achieved_score, 1)
              return facility_management_achieved if !facility_management_achieved
            else
              facility_management_targeted = is_valid?(smc.targeted_score, 1)
              return facility_management_targeted if !facility_management_targeted
            end
          elsif smc.scheme_criterion.scheme_category.code == 'IE'
            if is_submitted_score
              indoor_environment_submitted = is_valid?(smc.submitted_score, 1)
              return indoor_environment_submitted if !indoor_environment_submitted
            elsif is_achieved_score
              indoor_environment_achieved = is_valid?(smc.achieved_score, 1)
              return indoor_environment_achieved if !indoor_environment_achieved
              # return false
            else
              indoor_environment_targeted = is_valid?(smc.targeted_score, 1)
              return indoor_environment_targeted if !indoor_environment_targeted
            end
          elsif smc.scheme_criterion.scheme_category.code == 'WM'
            if is_submitted_score 
              waste_management_submitted = is_valid?(smc.submitted_score, 1)
              return waste_management_submitted if !waste_management_submitted
            elsif is_achieved_score
              waste_management_achieved = is_valid?(smc.achieved_score, 1)
              return waste_management_achieved if !waste_management_achieved
              # return false
            else
              waste_management_targeted = is_valid?(smc.targeted_score, 1)
              return waste_management_targeted if !waste_management_targeted
            end
          end
        end
        targated = facility_management_targeted && indoor_environment_targeted && waste_management_targeted
        sumitted = facility_management_submitted && indoor_environment_submitted && waste_management_submitted
        archived = facility_management_achieved && indoor_environment_achieved && waste_management_achieved

        if is_achieved_score
          return archived
        elsif is_submitted_score
          return sumitted
        else
          return targated
        end
      elsif scheme_mix.scheme.name == 'Premium Scheme'
        return 'Premium Scheme'
      elsif scheme_mix.scheme.name == 'Energy Neutral Mark'
        energy_targeted = energy_sumitted = energy_achieved = false

        scheme_mix.scheme_mix_criteria.each do |smc|
          if smc.scheme_mix_criterion_boxes&.last&.is_checked?
            if smc.scheme_criterion.scheme_category.code == 'E'
              if is_submitted_score
                energy_sumitted = is_valid?(smc.submitted_score, 3)
                return energy_sumitted if !energy_sumitted
              elsif is_achieved_score
                energy_achieved = is_valid?(smc.achieved_score, 3)
                return energy_achieved if !energy_achieved
              else
                energy_targeted = is_valid?(smc.targeted_score, 3)
                return energy_targeted if !energy_targeted
              end
            end
          else
            return false
          end
        end

        if is_submitted_score
          return energy_sumitted
        elsif is_achieved_score
          return energy_achieved
        else
          return energy_targeted
        end

      else # Standard Scheme
        return 'Standard Scheme'
      end
    end
    return true
  end

  def is_valid?(smc_score, target)
    if smc_score >= target
      return true
    else
      return false
    end
  end

  def max_gold(score)
    if score < 0.5
      return 'CERTIFICATION DENIED'
    elsif score >= 0.5 && score < 1
      return 'BRONZE'
    elsif score >= 1 && score < 1.5
      return 'SILVER'
    elsif score >= 1.5
      return 'GOLD'
    else
      return -1
    end    
  end

  def max_diamond(score)
    if score < 0.5
      return 'CERTIFICATION DENIED'
    elsif score >= 0.5 && score < 1
      return 'BRONZE'
    elsif score >= 1 && score < 1.5
      return 'SILVER'
    elsif score >= 1.5 && score < 2
      return 'GOLD'
    elsif score >= 2 && score < 2.5
      return 'PLATINUM'
    elsif score >= 2.5
      return 'DIAMOND'
    else
      return -1
    end
  end
  
  def rating_for_score(score, certificate: nil, certificate_gsb_version: nil, certificate_name: nil, is_achieved_score: true, is_submitted_score: true)
    return -1 if score.nil?

    if (!certificate.nil? && certificate.operations?) || (!certificate_name.nil? && certificate_name.include?('Operations'))
      if (!certificate.nil? && certificate.operations_2019?)
        label = allow_certification?(is_achieved_score: is_achieved_score, is_submitted_score: is_submitted_score)
        if label == false
          return 'CERTIFICATION DENIED'
        elsif label == true
          return 'CERTIFIED'
        elsif label == 'Standard Scheme'
          return max_gold(score)
        elsif label == 'Premium Scheme'
          return max_diamond(score)
        end
      end

      if score < 0.5
        return 'CERTIFICATION DENIED'
      elsif score >= 0.5 && score < 1
        return 'BRONZE'
      elsif score >= 1 && score < 1.5
        return 'SILVER'
      elsif score >= 1.5 && score < 2
        return 'GOLD'
      elsif score >= 2 && score < 2.5
        return 'PLATINUM'
      elsif score >= 2.5
        return 'DIAMOND'
      else
        return -1
      end
    elsif (!certificate.nil?) || (!certificate_gsb_version.nil? && certificate_gsb_version == 'v2.1 Issue 1.0')
      if score < 35
        return 'CERTIFICATION DENIED'
      elsif score >= 35 && score < 55
        return 'CLASS C'
      elsif score >= 55 && score < 65
        return 'CLASS B'
      elsif score >= 65 && score < 75
        return 'CLASS A'
      elsif score >= 75
        return 'CLASS A*'
      else
        return -1
      end
    elsif (!certificate.nil?) || (!certificate_gsb_version.nil? && certificate_gsb_version == 'v2.1 Issue 3.0')
      if score < 0.5
        return 'CERTIFICATION DENIED'
      elsif score >= 0.5 && score < 1
        return 'CLASS C'
      elsif score >= 1 && score < 1.5
        return 'CLASS B'
      elsif score >= 1.5 && score < 2
        return 'CLASS A'
      elsif score >= 2
        return 'CLASS A*'
      else
        return -1
      end
    elsif (!certificate.nil?) || (!certificate_gsb_version.nil? && certificate_gsb_version == '2019' && certificate_name.include?('Construction'))
      if score < 0.5
        return 'CERTIFICATION DENIED'
      elsif score >= 0.5 && score < 1
        return 'CLASS D'
      elsif score >= 1 && score < 1.5
        return 'CLASS C'
      elsif score >= 1.5 && score < 2
        return 'CLASS B'
      elsif score >= 2 && score < 2.5
        return 'CLASS A'
      elsif score >= 2.5
        return 'CLASS A*'
      else
        return -1
      end
    else
      if score < 0
        val = 'CERTIFICATION DENIED'
      elsif score >= 0 && score <= 0.5
        val = 1
      elsif score > 0.5 && score <= 1
        val = 2
      elsif score > 1 && score <= 1.5
        val = 3
      elsif score > 1.5 && score <= 2
        val = 4
      elsif score > 2 && score <= 2.5
        val = 5
      elsif score > 2.5 && score <= 3
        val = 6
      elsif score > 3 # due to incentive weights, you can actually score more than 3
        val = 6
      else
        val = -1
      end

      return val
    end
  end

  def is_valid_check?(flag)
    if flag
      return 'CERTIFIED'
    else
      return 'CERTIFICATION DENIED'
    end
  end

  def label_for_level(certificate: nil, is_targetted_score: true, is_achieved_score: true, is_submitted_score: true)
    main_scheme_mixes = self.main_scheme_mix.present? ? self.scheme_mixes.where(id: self.main_scheme_mix.id) : self.scheme_mixes
    main_scheme_mixes.each do |sm|
      sm.scheme_mix_criteria.each do |smc|
        smc.scheme_mix_criterion_boxes.each do |smcb|
          if is_submitted_score && smcb.scheme_criterion_box.label == "Submitted Checklist Status"
            return is_valid_check?(smcb.is_checked)
          elsif is_achieved_score && smcb.scheme_criterion_box.label == "Achieved Checklist Status"
            return is_valid_check?(smcb.is_checked)
          elsif is_targetted_score && smcb.scheme_criterion_box.label == "Targeted Checklist Status"
            return is_valid_check?(smcb.is_checked)
          end
        end
      end
    end
  end

  # This function is used for toggling writability of form elements in the certification path flow
  def in_submission?
    CertificationPathStatus::STATUSES_IN_SUBMISSION.include?(certification_path_status_id)
  end

  def in_screening?
    CertificationPathStatus::SCREENING == certification_path_status_id
  end

  # This function is used for toggling writability of form elements in the certification path flow
  def in_verification?
    CertificationPathStatus::STATUSES_IN_VERIFICATION.include?(certification_path_status_id)
  end

  # this function is used to toggle the visibility of the achieved score
  def in_pre_verification?
    CertificationPathStatus::STATUSES_IN_PRE_VERIFICATION.include?(certification_path_status_id)
  end

  def in_acknowledging?
    CertificationPathStatus::STATUSES_IN_ACKNOWLEDGING.include?(certification_path_status_id)
  end

  def is_activating?
    CertificationPathStatus::ACTIVATING == certification_path_status_id
  end

  def is_activated?
    CertificationPathStatus::STATUSES_ACTIVATED.include?(certification_path_status_id)
  end

  def is_submitting?
    certification_path_status_id == CertificationPathStatus::SUBMITTING
  end

  def is_completed?
    CertificationPathStatus::STATUSES_COMPLETED.include?(certification_path_status_id)
  end

  def is_certified?
    [CertificationPathStatus::CERTIFIED, CertificationPathStatus::CERTIFICATE_IN_PROCESS].include?(certification_path_status_id)
  end

  def is_checklist_method?
    CertificationPath.assessment_methods[assessment_method] == CertificationPath.assessment_methods[:check_list]
  end

  def is_design_loc?
    certificate.full_name.include?('Letter of Conformance') && certificate.design_and_build?
  end

  def is_design_fdc?
    certificate.full_name.include?('Final Design Certificate') && certificate.design_and_build?
  end

  private

  def create_cda_users
    project_managers = project.projects_users&.where(role: ["cgp_project_manager", "certification_manager"])
    project_managers.each do |project_manager|
      new_project_manager = project_manager.dup
      new_project_manager.certification_team_type = "Final Design Certificate"
      new_project_manager.save
    end
  end

  def create_certification_path_report
    certification_path_report = CertificationPathReport.find_or_initialize_by(certification_path_id: id)
    certification_path_report.save(validate: false)
  end

  def set_started_at
    if certification_path_status_id_changed? && certification_path_status_id == CertificationPathStatus::SUBMITTING
      self.started_at = Time.zone.now
    end
  end

  def set_certified_at
    if certification_path_status_id_changed? && is_completed?
      self.certified_at = Time.zone.now
    end
  end

  def advance_scheme_mix_criteria_statuses
    if certification_path_status_id_changed?
      case certification_path_status_id
        # If the certificate status is advanced to 'Screening',
        # clear the responsible user & due date of the requirements
      when CertificationPathStatus::SCREENING
        scheme_mix_criteria.update_all(certifier_id: nil, due_date: nil)
        scheme_mix_criteria.each do |smc|
          smc.requirement_data.update_all(user_id: nil, due_date: nil)
        end
        # If the certificate status is advanced to 'Submitting after screening',
        # clear the responsible certifier & due date of the criteria
      when CertificationPathStatus::SUBMITTING_AFTER_SCREENING
        scheme_mix_criteria.update_all(certifier_id: nil, due_date: nil)
        # If the certificate status is advanced to 'Verifying',
        # clear the responsible user & due date of the requirements
        # and advance the status of all submitted criteria to 'Verifying'
      when CertificationPathStatus::VERIFYING
        scheme_mix_criteria.update_all(certifier_id: nil, due_date: nil)
        scheme_mix_criteria.each do |smc|
          smc.requirement_data.update_all(user_id: nil, due_date: nil)
          if smc.submitted?
            smc.verifying!
          end
        end
        # If the certificate status is advanced to 'Submitting after appeal',
        # also advance the status of all appealed criteria to 'Submitting after appeal'
      when CertificationPathStatus::SUBMITTING_AFTER_APPEAL
        scheme_mix_criteria.update_all(certifier_id: nil, due_date: nil)
        scheme_mix_criteria.each do |smc|
          if smc.appealed?
            smc.submitting_after_appeal!
            # Reset linked requirements to 'required' and unassign from project team member
            smc.requirement_data.each do |requirement|
              requirement.required!
            end
          end
        end
        # If the certificate status is advanced to 'Acknowledging',
        # clear the responsible certifier & due date of the criteria
      when CertificationPathStatus::ACKNOWLEDGING
        scheme_mix_criteria.update_all(certifier_id: nil, due_date: nil)
        # If the certificate status is advanced to 'Verifying after appeal',
        # clear the responsible user & due date of the requirements
        # and advance the status of all appealed criteria to 'Verifying after appeal'
      when CertificationPathStatus::VERIFYING_AFTER_APPEAL
        scheme_mix_criteria.each do |smc|
          smc.requirement_data.update_all(user_id: nil, due_date: nil)
          if smc.submitted_after_appeal?
            smc.verifying_after_appeal!
          end
        end
        # If the certificate status is advanced to 'Acknowledging after appeal',
        # clear the responsible certifier & due date of the criteria
      when CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL
        scheme_mix_criteria.update_all(certifier_id: nil, due_date: nil)
      end
    end
  end

  # Triggers the 'create_descendant_records' method of underlying scheme mixes
  def create_descendant_records
    # Only trigger when the certification path is being activated
    if certification_path_status_id_changed? && (certification_path_status_id_was == CertificationPathStatus::ACTIVATING)
      DigestMailer.send_project_activated_email_to_project_owner(self).deliver_now
      CertificationPath.transaction do
        # If there is a main scheme mix, it should be handled first
        if (development_type.mixable? && main_scheme_mix.present?)
          main_scheme_mix.create_descendant_records
          scheme_mixes.where.not(id: main_scheme_mix_id).each do |scheme_mix|
            scheme_mix.create_descendant_records
          end
          # If there is no main scheme mix, order doesn't matter
        else
          scheme_mixes.each do |scheme_mix|
            scheme_mix.create_descendant_records
          end
        end
      end
    end
  end

  def send_applied_for_certification_email
    DigestMailer.applied_for_certification(self).deliver_now
  end

  def revised_score(val, is_achieved_score, is_submitted_score)
    e6_criterion = scheme_mix_criteria&.joins(scheme_criterion: :scheme_category).find_by("scheme_categories.name = 'Energy' AND scheme_criteria.name = 'Renewable Energy'")
    val = if e6_criterion.present? && ((is_submitted_score && e6_criterion&.submitted_score_a.to_f < 3) || (is_achieved_score && e6_criterion&.achieved_score_a.to_f < 3) || (!is_achieved_score && !is_submitted_score && e6_criterion&.targeted_score_a.to_f < 3))
            4
          else
            val
          end
    return val
  end
end
