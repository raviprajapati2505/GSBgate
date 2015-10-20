class CertificationPath < ActiveRecord::Base
  include Auditable
  include Taskable

  belongs_to :project
  belongs_to :certificate
  belongs_to :certification_path_status
  has_many :scheme_mixes
  has_many :schemes, through: :scheme_mixes
  has_many :scheme_mix_criteria, through: :scheme_mixes
  has_many :scheme_mix_criteria_documents, through: :scheme_mix_criteria
  has_many :scheme_mix_criteria_requirement_data, through: :scheme_mix_criteria
  has_many :requirement_data, through: :scheme_mix_criteria_requirement_data
  has_many :task, dependent: :destroy

  accepts_nested_attributes_for :certificate
  accepts_nested_attributes_for :scheme_mixes

  enum development_type: {not_applicable: 0, single_use: 1, mixed_use: 2, mixed_development: 3, mixed_development_in_stages: 4}

  validates :project, presence: true
  validates :certificate, presence: true
  validates_inclusion_of :development_type, in: CertificationPath.development_types.keys
  validate :total_weight_is_equal_to_100_percent
  validate :certificate_duration

  after_initialize :init
  before_update :set_certified_at
  after_update :advance_scheme_mix_criteria_statuses

  scope :with_status, ->(status) {
    where(certification_path_status_id: status)
  }

  scope :letter_of_conformance, -> {
    joins(:certificate)
        .merge(Certificate.letter_of_conformance)
  }

  scope :final_design_certificate, -> {
    joins(:certificate)
        .merge(Certificate.final_design_certificate)
  }

  scope :construction_certificate, -> {
    joins(:certificate)
        .merge(Certificate.construction_certificate)
  }

  scope :operations_certificate, -> {
    joins(:certificate)
        .merge(Certificate.operations_certificate)
  }

  def init
    # Set status
    self.certification_path_status_id ||= CertificationPathStatus::ACTIVATING
  end

  def name
    self.certificate.name
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

  def total_weighted_targeted_score_relative_to_certification_path
    total = nil
    scheme_mixes.each do |sm|
      total ||= 0
      total += sm.total_weighted_targeted_score_relative_to_certification_path
    end
    total.nil? ? -1 : total
  end

  def total_weighted_submitted_score_relative_to_certification_path
    total = nil
    scheme_mixes.each do |sm|
      total ||= 0
      total += sm.total_weighted_submitted_score_relative_to_certification_path
    end
    total.nil? ? -1 : total
  end

  def total_weighted_achieved_score_relative_to_certification_path
    total = nil
    scheme_mixes.each do |sm|
      total ||= 0
      total += sm.total_weighted_achieved_score_relative_to_certification_path
    end
    total.nil? ? -1 : total
  end

  def targeted_star_rating
    CertificationPath.star_rating_for_score(total_weighted_targeted_score_relative_to_certification_path)
  end

  def submitted_star_rating
    CertificationPath.star_rating_for_score(total_weighted_sumitted_score_relative_to_certification_path)
  end

  def achieved_star_rating
    CertificationPath.star_rating_for_score(total_weighted_achieved_score_relative_to_certification_path)
  end

  def total_weight
    total = nil
    scheme_mixes.each do |sm|
      total ||= 0
      total += sm.weight
    end
    total.nil? ? 0 : total
  end

  def total_weight_is_equal_to_100_percent
    if total_weight != 100
      errors.add(:scheme_mixes, 'Scheme weights should total 100%.')
    end
  end

  def certificate_duration
    if certificate.letter_of_conformance?
      if duration != 1
        errors.add(:duration, 'Duration for Letter of Conformance should be 1 year.')
      end
    elsif certificate.final_design_certificate?
      if not [2, 3, 4].include? duration
        errors.add(:duration, 'Duration for Final Design Certificate should be 2, 3 or 4 years.')
      end
    elsif certificate.construction_certificate? or certificate.operations_certificate?
    end
  end

  # Checks if a user has permission to advance the certificate path to the next status
  def can_advance_status?(user)
    unless [CertificationPathStatus::CERTIFIED, CertificationPathStatus::NOT_CERTIFIED].include?(certification_path_status_id)
      case CertificationPathStatus.waiting_fors[certification_path_status.waiting_for]
        when CertificationPathStatus.waiting_fors[:project_manager]
          return user.project_manager?(project)
        when CertificationPathStatus.waiting_fors[:certifier_manager]
          return user.certifier_manager?(project)
        when CertificationPathStatus.waiting_fors[:system_admin]
          return user.system_admin?
        when CertificationPathStatus.waiting_fors[:gord_manager]
          return user.gord_manager?
        when CertificationPathStatus.waiting_fors[:gord_top_manager]
          return user.gord_top_manager?
        else
          return false
      end
    end
    return false
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
        if pcr_track?
          if pcr_track_allowed?
            return CertificationPathStatus::SUBMITTING_PCR
          else
            return CertificationPathStatus::PROCESSING_PCR_PAYMENT
          end
        else
          return CertificationPathStatus::VERIFYING
        end
      when CertificationPathStatus::PROCESSING_PCR_PAYMENT
        return CertificationPathStatus::SUBMITTING_PCR
      when CertificationPathStatus::SUBMITTING_PCR
        return CertificationPathStatus::VERIFYING
      when CertificationPathStatus::VERIFYING
        return CertificationPathStatus::ACKNOWLEDGING
      when CertificationPathStatus::ACKNOWLEDGING
        if appealed?
          return CertificationPathStatus::PROCESSING_APPEAL_PAYMENT
        else
          return CertificationPathStatus::APPROVING_BY_MANAGEMENT
        end
      when CertificationPathStatus::PROCESSING_APPEAL_PAYMENT
        return CertificationPathStatus::SUBMITTING_AFTER_APPEAL
      when CertificationPathStatus::SUBMITTING_AFTER_APPEAL
        return CertificationPathStatus::VERIFYING_AFTER_APPEAL
      when CertificationPathStatus::VERIFYING_AFTER_APPEAL
        return CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL
      when CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL
        return CertificationPathStatus::APPROVING_BY_MANAGEMENT
      when CertificationPathStatus::APPROVING_BY_MANAGEMENT
        return CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT
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
        unless project.certifier_manager_assigned?
          todos << 'A certifier manager must be assigned to the project.'
        end
      when CertificationPathStatus::SUBMITTING, CertificationPathStatus::SUBMITTING_AFTER_SCREENING, CertificationPathStatus::SUBMITTING_PCR, CertificationPathStatus::SUBMITTING_AFTER_APPEAL
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
          if criterion.targeted_score.blank?
            todos << 'Every criterion should have a targeted score.'
          end
          if criterion.submitted_score.blank?
            todos << 'Every criterion should have a submitted score.'
          end
          if criterion.submitting?
            todos << 'Some criteria still have status \'Submitting\'.'
          end
          if criterion.submitting_after_appeal?
            todos << 'Some criteria still have status \'Submitting after appeal\'.'
          end
        end
      when CertificationPathStatus::PROCESSING_PCR_PAYMENT
        unless pcr_track_allowed?
          todos << 'The PCR track allowed flag must be set.'
        end
      when CertificationPathStatus::VERIFYING, CertificationPathStatus::VERIFYING_AFTER_APPEAL
        scheme_mix_criteria.each do |criterion|
          if criterion.achieved_score.blank?
            todos << 'Every criterion should have an achieved score.'
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

    return todos
  end

  def self.star_rating_for_score(score)
    if score < 0
      return 0
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

  # This function is used for toggling writability of form elements in the certification path flow
  def in_submission?
    return [CertificationPathStatus::SUBMITTING,
            CertificationPathStatus::SUBMITTING_AFTER_SCREENING,
            CertificationPathStatus::SUBMITTING_PCR,
            CertificationPathStatus::SUBMITTING_AFTER_APPEAL].include?(certification_path_status_id)
  end

  # This function is used for toggling writability of form elements in the certification path flow
  def in_verification?
    return [CertificationPathStatus::SCREENING,
            CertificationPathStatus::VERIFYING,
            CertificationPathStatus::VERIFYING_AFTER_APPEAL].include?(certification_path_status_id)
  end

  # this function is used to toggle the visibility of the achieved score
  def in_pre_verification?
    return [CertificationPathStatus::ACTIVATING,
            CertificationPathStatus::SUBMITTING,
            CertificationPathStatus::SCREENING,
            CertificationPathStatus::SUBMITTING_AFTER_SCREENING,
            CertificationPathStatus::PROCESSING_PCR_PAYMENT,
            CertificationPathStatus::SUBMITTING_PCR].include?(certification_path_status_id)
  end

  def is_completed?
    return [CertificationPathStatus::CERTIFIED,
            CertificationPathStatus::NOT_CERTIFIED].include?(certification_path_status_id)
  end

  def is_certified?
    return [CertificationPathStatus::CERTIFIED].include?(certification_path_status_id)
  end

  private

  def set_certified_at
    if is_completed?
      self.certified_at = DateTime.now
    end
  end

  def advance_scheme_mix_criteria_statuses
    CertificationPath.transaction do
      if certification_path_status_id_changed?
        case certification_path_status_id
          # If the certificate status is advanced to 'Verifying',
          # also advance the status of all submitted criteria to 'Verifying'
          when CertificationPathStatus::VERIFYING
            scheme_mix_criteria.each do |smc|
              if smc.submitted?
                smc.verifying!
              end
            end
          # If the certificate status is advanced to 'Submitting after appeal',
          # also advance the status of all appealed criteria to 'Submitting after appeal'
          when CertificationPathStatus::SUBMITTING_AFTER_APPEAL
            scheme_mix_criteria.each do |smc|
              if smc.appealed?
                smc.submitting_after_appeal!
              end
            end
          # If the certificate status is advanced to 'Verifying after appeal',
          # also advance the status of all appealed criteria to 'Verifying after appeal'
          when CertificationPathStatus::VERIFYING_AFTER_APPEAL
            scheme_mix_criteria.each do |smc|
              if smc.submitted_after_appeal?
                smc.verifying_after_appeal!
              end
            end
        end
      end
    end
  end
end
