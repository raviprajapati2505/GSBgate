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

  enum development_type: { not_applicable: 0, single_use: 1, mixed_use: 2, mixed_development: 3, mixed_development_in_stages: 4 }

  validates :project, presence: true
  validates :certificate, presence: true
  validates_inclusion_of :development_type, in: CertificationPath.development_types.keys
  validate :total_weight_is_equal_to_100_percent
  validate :certificate_duration

  after_initialize :init
  before_update :set_certified_at

  scope :with_status, ->(status) {
    where(certification_path_status_id: status)
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
      status_history << { date: audit_log.created_at, certification_path_status: CertificationPathStatus.find_by_id(audit_log.new_status) }
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
      if not [2,3,4].include? duration
        errors.add(:duration, 'Duration for Final Design Certificate should be 2, 3 or 4 years.')
      end
    elsif certificate.construction_certificate? or certificate.operations_certificate?
    end
  end

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
      end
    end
    return false
  end

  # return an error message if not all conditions are met to advance to the next status
  # returns a CertificationPathStatus id otherwise
  def next_status
    error = catch(:error) do
      case certification_path_status_id
        when CertificationPathStatus::ACTIVATING
          # Only system_admin can change status
          if can_leave_activating_status?
            return CertificationPathStatus::SUBMITTING
          end
        when CertificationPathStatus::SUBMITTING
          # Only system_admin and project mngr can change status
          if can_leave_submitting_status?
            return CertificationPathStatus::SCREENING
          end
        when CertificationPathStatus::SCREENING
          # Only system_admin and certifier mngr can change status
          if can_leave_screening_status?
            return CertificationPathStatus::SUBMITTING_AFTER_SCREENING
          end
        when CertificationPathStatus::SUBMITTING_AFTER_SCREENING
          # Only system_admin and project mngr can change status
          if can_leave_submitting_after_screening_status?
            # The next status depends on the PCR track flag
            if pcr_track?
              return CertificationPathStatus::PROCESSING_PCR_PAYMENT
            else
              return CertificationPathStatus::VERIFYING
            end
          end
        when CertificationPathStatus::PROCESSING_PCR_PAYMENT
          # Only system_admin can change status
          if can_leave_processing_pcr_payment_status?
            return CertificationPathStatus::SUBMITTING_PCR
          end
        when CertificationPathStatus::SUBMITTING_PCR
          # Only system_admin, certifier mngr and project mngr can change status
          if can_leave_submitting_pcr_status?
            return CertificationPathStatus::VERIFYING
          end
        when CertificationPathStatus::VERIFYING
          # Only system_admin and certifier mngr can change status
          if can_leave_verifying_status?
            # The next status depends on the outcome of the verification process
            # TODO when is a certification path rejected ?
            return CertificationPathStatus::ACKNOWLEDGING
          end
        when CertificationPathStatus::ACKNOWLEDGING
          # Only system_admin and project mngr can change status
          if can_leave_acknowledging_status?
            if appealed?
              return CertificationPathStatus::PROCESSING_APPEAL_PAYMENT
            else
              return CertificationPathStatus::APPROVING_BY_MANAGEMENT
            end
          end
        when CertificationPathStatus::PROCESSING_APPEAL_PAYMENT
          # Only system_admin can change status
          if can_leave_processing_appeal_payment_status?
            return CertificationPathStatus::SUBMITTING_AFTER_APPEAL
          end
        when CertificationPathStatus::SUBMITTING_AFTER_APPEAL
          # Only system_admin and project mngr can change status
          if can_leave_submitting_after_appeal_status?
            return CertificationPathStatus::VERIFYING_AFTER_APPEAL
          end
        when CertificationPathStatus::VERIFYING_AFTER_APPEAL
          # Only system_admin and certifier mngr can change status
          if can_leave_verifying_after_appeal_status?
            # The next status depends on the outcome of the verification process
            # TODO when is a certification path rejected ?
            return CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL
          end
        when CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL
          # Only system_admin and project mngr can change status
          if can_leave_acknowledging_after_appeal_status?
            return CertificationPathStatus::APPROVING_BY_MANAGEMENT
          end
        when CertificationPathStatus::APPROVING_BY_MANAGEMENT
          # Only GORD mngr and GORD top mngr can change status
          if can_leave_approving_by_management_status?
            return CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT
          end
        when CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT
          # Only GORD mngr and GORD top mngr can change status
          if can_leave_approving_by_top_management_status?
            return CertificationPathStatus::CERTIFIED
          end
        when CertificationPathStatus::CERTIFIED, CertificationPathStatus::NOT_CERTIFIED
          # There is no next status
          throw(:error, 'There is no next status.')
      end
    end
    return error
  end

  def previous_status
    # only system_admin can use this function
    # TODO provide code for previous_status
    raise NotImplementedError
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

  # Conditions are
  #  1) certification path is not expired
  #  2) certification path payment received
  #  3) project details are provided
  #  4) certifier mngr is assigned
  def can_leave_activating_status?
    # TODO certification path expiry date
    # certifier mngr is assigned
    if project.certifier_manager_assigned?
      return true
    end
    throw(:error, 'A certifier manager must be assigned to the project first.')
  end

  # Conditions are
  #  1) all general submittals are provided
  #  2) all criteria are completed (= when all linked requirements and submitted scores are provided and no more documents waiting for approval)
  def can_leave_submitting_status?
    ['location_plan_file', 'site_plan_file', 'design_brief_file', 'project_narrative_file'].each do |general_submittal|
      if project.send(general_submittal).blank?
        throw(:error, 'Please add a \'' + Project.human_attribute_name(general_submittal) + '\' to the project first.')
      end
    end

    scheme_mix_criteria.each do |criterion|
      # all linked requirements are provided
      if criterion.has_required_requirements?
        throw(:error, 'There are still requirements in status \'required\'.')
      end
      # no more documents waiting for approval
      if criterion.has_documents_awaiting_approval?
        throw(:error, 'There are still documents awaiting approval.')
      end
      # all criteria are completed
      if criterion.in_progress?
        throw(:error, 'All criteria must have status different from \'in progress\'.')
      end
      # all submitted scores provided
      if criterion.submitted_score.blank?
        throw(:error, 'There are submitted scores missing.')
      end
    end
    return true
  end

  # Conditions are
  #  1) all criteria are screened
  def can_leave_screening_status?
    return true
  end

  # Conditions are
  #  1) all criteria are completed (= when all linked requirements and submitted scores are provided and no more documents waiting for approval)
  def can_leave_submitting_after_screening_status?
    can_leave_submitting_status?
  end

  # Conditions are
  #  1) PCR track payment received
  def can_leave_processing_pcr_payment_status?
    if pcr_track_allowed?
      return true
    end
    throw(:error, 'The PCR track allowed flag must be set first.')
  end

  # Conditions are
  #  1) all criteria are reviewed
  def can_leave_submitting_pcr_status?
    can_leave_submitting_status?
  end

  # Conditions are
  #  1) all criteria are verified (= when all achieved scores are provided)
  def can_leave_verifying_status?
    scheme_mix_criteria.each do |criterion|
      unless criterion.approved? || criterion.resubmit?
        throw(:error, 'There are still criteria in status \'complete\'.')
      end
      if criterion.achieved_score.blank?
        throw(:error, 'There are achieved scores missing.')
      end
    end
    return true
  end

  # Conditions are
  #  none
  def can_leave_acknowledging_status?
    return true
  end

  # Conditions are
  #  1) payment received
  def can_leave_processing_appeal_payment_status?
    return true
  end

  # Conditions are
  #  1) all appealed criteria are completed (= when all linked requirements and submitted scores are provided and no more documents waiting for approval)
  def can_leave_submitting_after_appeal_status?
    can_leave_submitting_status?
  end

  # Conditions are
  #  1) all criteria are verified (= when all achieved scores are provided)
  def can_leave_verifying_after_appeal_status?
    scheme_mix_criteria.each do |criterion|
      unless criterion.approved? || criterion.resubmit?
        throw(:error, 'There are still criteria in status \'complete\'.')
      end
      if criterion.achieved_score.blank?
        throw(:error, 'There are achieved scores missing.')
      end
    end
    return true
  end

  # Conditions are
  #  none
  def can_leave_acknowledging_after_appeal_status?
    return true
  end

  # Conditions are
  #  none
  def can_leave_approving_by_management_status?
    return true
  end

  # Conditions are
  #  none
  def can_leave_approving_by_top_management_status?
    return true
  end
end
