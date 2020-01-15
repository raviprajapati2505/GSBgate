require 'file_size_validator'

class CertificationPath < ApplicationRecord
  include ActionView::Helpers::TranslationHelper
  include Auditable
  include Taskable
  include DatePlucker
  include ScoreCalculator

  MAXIMUM_DOCUMENT_FILE_SIZE = 100 # in MB

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

  scope :not_expired, -> {
    where('expires_at > ?', DateTime.now)
  }

  scope :with_status, ->(statuses) {
    joins(:certification_path_status).where(certification_path_status_id: statuses)
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
    self.certification_path_status.name
  end

  def status_history
    audit_logs = self.audit_logs.where('new_status IS NOT NULL')
    status_history = []
    audit_logs.each do |audit_log|
      status_history << {date: audit_log.created_at, certification_path_status: CertificationPathStatus.find_by_id(audit_log.new_status)}
    end
    status_history
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
      if self.certificate.construction_type?
        return CertificationPathStatus::CERTIFIED
      else
        return CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT
      end
    when CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT
      return CertificationPathStatus::CERTIFIED
    else
      return false
    end
  end

  def previous_status
    # only system_admin can use this function
    # TODO provide code for previous_status
    raise NotImplementedError
  end

  def todo_before_status_advance
    todos = []

    case certification_path_status_id
    when CertificationPathStatus::ACTIVATING
      # TODO certification path expiry date
      unless project.certification_manager_assigned?
        todos << 'A certification manager must be assigned to the project.'
      end
      if development_type.mixable? && (main_scheme_mix_selected? == false)
        todos << 'A main scheme needs to be selected.'
      end
    when CertificationPathStatus::SCREENING
      scheme_mix_criteria.each do |criterion|
        unless criterion.screened
          todos << 'Some criteria aren\'t screened yet. Please allocate team responsibility for screening or skip screening by marking all criteria as "screened".'
        end
      end
    when CertificationPathStatus::SUBMITTING, CertificationPathStatus::SUBMITTING_AFTER_SCREENING, CertificationPathStatus::SUBMITTING_AFTER_APPEAL
      ['location_plan_file', 'site_plan_file', 'design_brief_file', 'project_narrative_file'].each do |general_submittal|
        if project.send(general_submittal).blank?
          todos << "A '#{Project.human_attribute_name(general_submittal)}' must be added to the project."
        end
      end
      scheme_mix_criteria.each do |criterion|
        if criterion.has_required_requirements?
          todos << 'All requirements should have status \'Provided\' or \'Not required\'.'
        end
        if criterion.has_documents_awaiting_approval?
          todos << 'There are still documents awaiting approval.'
        end
        SchemeMixCriterion::TARGETED_SCORE_ATTRIBUTES.each_with_index do |targeted_score, index|
          unless criterion.scheme_criterion.read_attribute(SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym).nil?
            if criterion.read_attribute(targeted_score.to_sym).blank?
              todos << 'Every criterion should have a targeted level.'
              break
            end
          end
        end
        criteria_exist_blank = false
        SchemeMixCriterion::SUBMITTED_SCORE_ATTRIBUTES.each_with_index do |submitted_score, index|
          unless criterion.scheme_criterion.read_attribute(SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym).nil?
            if criterion.read_attribute(submitted_score.to_sym).blank?
              criteria_exist_blank = true
              todos << 'Every criterion should have a submitted level.'
              break
            end
          end
        end
        unless User.current.can?(:edit_status_low_score, self) || criteria_exist_blank
          if ['E','W'].include?(criterion.scheme_criterion.scheme_category.code) && self.certificate.construction_issue_3? && (criterion.submitted_score <= 0)
            todos << 'To obtain GSAS certification for Construction the Energy and Water criteria levels must be higher than 0.'
          end

          if self.certificate.operations?
            if (criterion.scheme_criterion.scheme_category.scheme.name == 'Healthy Building Label Scheme') && (criterion.submitted_score < 2)
              todos << 'To obtain GSAS certification for the Healthy Building Label scheme all criteria levels must be 2 or higher.'
            elsif ['E','W'].include?(criterion.scheme_criterion.scheme_category.code) && (criterion.submitted_score <= 0)
              todos << 'To obtain GSAS certification for Standard or Premium scheme the Energy and Water criteria levels must be higher than 0.'
            end

            if (criterion.scheme_criterion.scheme_category.scheme.name == 'Premium Scheme') && (criterion.scheme_criterion.scheme_category.code == 'IE') && (criterion.scheme_criterion.number == 2) && (criterion.submitted_score <= 0)
              todos << 'To obtain GSAS certification for Premium scheme the level of IE.2 Air Quality must be higher than 0.'
            end
          end
        end
        if criterion.submitting?
          todos << 'Some criteria still have status \'Submitting\'.'
        end
        if criterion.submitting_after_appeal?
          todos << 'Some criteria still have status \'Submitting after appeal\'.'
        end
      end
    when CertificationPathStatus::VERIFYING, CertificationPathStatus::VERIFYING_AFTER_APPEAL
      scheme_mix_criteria.each do |criterion|
        SchemeMixCriterion::ACHIEVED_SCORE_ATTRIBUTES.each_with_index do |achieved_score, index|
          unless criterion.scheme_criterion.read_attribute(SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym).nil?
            if criterion.read_attribute(achieved_score.to_sym).blank?
              todos << 'Every criterion should have an achieved level.'
            end
          end
        end
        if criterion.verifying?
          todos << 'Some criteria still have status \'Verifying\'.'
        end
        if criterion.verifying_after_appeal?
          todos << 'Some criteria still have status \'Verifying after appeal\'.'
        end
      end
    when CertificationPathStatus::CERTIFIED, CertificationPathStatus::NOT_CERTIFIED
      todos << 'This is the final status.'
    end

    return todos.uniq
  end

  def self.rating_for_score(score, certificate: nil, certificate_gsas_version: nil, certificate_name: nil)
    return -1 if score.nil?

    if (!certificate.nil? && certificate.operations?) || (!certificate_name.nil? && certificate_name.include?('Operations'))
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
    elsif (!certificate.nil? && certificate.construction_issue_1?) || (!certificate_gsas_version.nil? && certificate_gsas_version == 'v2.1 Issue 1.0')
      if score < 35
        return 'CERTIFICATION DENIED'
      elsif score >= 35 && score < 65
        return 2
      elsif score >= 65 && score < 85
        return 4
      elsif score >= 85 && score <= 100
        return 6
      else
        return -1
      end
    elsif (!certificate.nil? && certificate.construction_issue_3?) || (!certificate_gsas_version.nil? && certificate_gsas_version == 'v2.1 Issue 3.0')
      if score < 0.5
        return 'CERTIFICATION DENIED'
      elsif score >= 0.5 && score < 1
        return 2
      elsif score >= 1 && score < 1.5
        return 3
      elsif score >= 1.5 && score < 2
        return 4
      elsif score >= 2 && score < 2.5
        return 5
      elsif score >= 2.5
        return 6
      else
        return -1
      end
    elsif (!certificate.nil? && certificate.construction_2019?) || (!certificate_gsas_version.nil? && certificate_gsas_version == '2019' && certificate_name.include?('Construction'))
      if score < 0.5
        return 'CERTIFICATION DENIED'
      elsif score >= 0.5 && score < 1.0
        return 'CLASS D'
      elsif score >= 1.0 && score < 1.5
        return 'CLASS C'
      elsif score >= 1.5 && score < 2.0
        return 'CLASS B'
      elsif score >= 2.0 && score < 2.5
        return 'CLASS A'
      elsif score >= 2.5
        return 'CLASS A*'
      else
        return -1
      end
    else
      if score < 0
        return 'CERTIFICATION DENIED'
      elsif score >= 0 && score <= 0.5
        return 1
      elsif score > 0.5 && score <= 1
        return 2
      elsif score > 1 && score <= 1.5
        return 3
      elsif score > 1.5 && score <= 2
        return 4
      elsif score > 2 && score <= 2.5
        return 5
      elsif score > 2.5 && score <= 3
        return 6
      elsif score > 3 # due to incentive weights, you can actually score more than 3
        return 6
      else
        return -1
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

  def is_completed?
    CertificationPathStatus::STATUSES_COMPLETED.include?(certification_path_status_id)
  end

  def is_certified?
    CertificationPathStatus::CERTIFIED == certification_path_status_id
  end

  private

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
end
