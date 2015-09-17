class CertificationPath < AuditableRecord
  belongs_to :project
  belongs_to :certificate
  has_many :scheme_mixes
  has_many :schemes, through: :scheme_mixes
  has_many :scheme_mix_criteria, through: :scheme_mixes
  has_many :scheme_mix_criteria_documents, through: :scheme_mix_criteria
  has_many :scheme_mix_criteria_requirement_data, through: :scheme_mix_criteria
  has_many :requirement_data, through: :scheme_mix_criteria_requirement_data

  accepts_nested_attributes_for :certificate
  accepts_nested_attributes_for :scheme_mixes

  enum development_type: { not_applicable: 0, single_use: 1, mixed_use: 2, mixed_development: 3, mixed_development_in_stages: 4 }
  enum status: { awaiting_activation: 0, awaiting_submission: 1, awaiting_screening: 2, awaiting_submission_after_screening: 3, awaiting_pcr_payment: 4, awaiting_submission_after_pcr: 5, awaiting_verification: 6, awaiting_approval_or_appeal: 7, awaiting_appeal_payment: 8, awaiting_submission_after_appeal: 9, awaiting_verification_after_appeal: 10, awaiting_approval_after_appeal: 11, awaiting_management_approvals: 12, certified: 13 }

  validates :project, :presence => true
  validates :certificate, :presence => true
  validates_inclusion_of :development_type, in: CertificationPath.development_types.keys
  validates_inclusion_of :status, in: CertificationPath.statuses.keys

  def name
    self.certificate.name
  end

  def has_fixed_scheme?
    certificate.schemes.count == 1
  end

  def total_weighted_targeted_score
    total = nil
    scheme_mixes.each do |sm|
      total ||= 0
      total += sm.total_weighted_targeted_score
    end
    total.nil? ? -1 : total
  end

  def total_weighted_submitted_score
    total = nil
    scheme_mixes.each do |sm|
      total ||= 0
      total += sm.total_weighted_submitted_score
    end
    total.nil? ? -1 : total
  end

  def total_weighted_achieved_score
    total = nil
    scheme_mixes.each do |sm|
      total ||= 0
      total += sm.total_weighted_achieved_score
    end
    total.nil? ? -1 : total
  end

  def star_rating_for_score(score)
    if score >= 0 && score <= 0.5
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
    else
      return -1
    end
  end

  # returns false if not all conditions are met to advance to the next status
  # returns one of CertificationPath.statuses otherwise
  def next_status
    error = catch(:error) do
      case status
        when CertificationPath.statuses[:awaiting_activation]
          # Only system_admin can change status
          if can_leave_awaiting_activation_status?
            return CertificationPath.statuses[:awaiting_submission]
          end
        when CertificationPath.statuses[:awaiting_submission]
          # Only system_admin and project mngr can change status
          if can_leave_awaiting_submission_status?
            return CertificationPath.statuses[:awaiting_screening]
          end
        when CertificationPath.statuses[:awaiting_screening]
          # Only system_admin and certifier mngr can change status
          if can_leave_awaiting_screening_status?
            return CertificationPath.statuses[:awaiting_submission_after_screening]
          end
        when CertificationPath.statuses[:awaiting_submission_after_screening]
          # Only system_admin and project mngr can change status
          if can_leave_awaiting_submission_after_screening_status?
            # The next status depends on the PCR track flag
            if pcr_track?
              return CertificationPath.statuses[:awaiting_pcr_payment]
            else
              return CertificationPath.statuses[:awaiting_verification]
            end
          end
        when CertificationPath.statuses[:awaiting_pcr_payment]
          # Only system_admin can change status
          if can_leave_awaiting_pcr_payment_status?
            return CertificationPath.statuses[:awaiting_submission_after_pcr]
          end
        when CertificationPath.statuses[:awaiting_submission_after_pcr]
          # Only system_admin, certifier mngr and project mngr can change status
          if can_leave_awaiting_submission_after_pcr_status?
            return CertificationPath.statuses[:awaiting_verification]
          end
        when CertificationPath.statuses[:awaiting_verification]
          # Only system_admin and certifier mngr can change status
          if can_leave_awaiting_verification_status?
            # The next status depends on the outcome of the verification process
            # TODO when is a certification path rejected ?
            return CertificationPath.statuses[:awaiting_approval_or_appeal]
          end
        when CertificationPath.statuses[:awaiting_approval_or_appeal]
          # Only system_admin and project mngr can change status
          if can_leave_awaiting_approval_or_appeal_status?
            # The next status depends if appealed for at least 1 criterion
            # TODO implement appeal
            return CertificationPath.statuses[:awaiting_management_approvals]
          end
        when CertificationPath.statuses[:awaiting_appeal_payment]
          # Only system_admin can change status
          if can_leave_awaiting_appeal_payment_status?
            return CertificationPath.statuses[:awaiting_submission_after_appeal]
          end
        when CertificationPath.statuses[:awaiting_submission_after_appeal]
          # Only system_admin and project mngr can change status
          if can_leave_awaiting_submission_after_appeal_status?
            return CertificationPath.statuses[:awaiting_verification_after_appeal]
          end
        when CertificationPath.statuses[:awaiting_verification_after_appeal]
          # Only system_admin and certifier mngr can change status
          if can_leave_awaiting_verification_after_appeal_status?
            # The next status depends on the outcome of the verification process
            # TODO when is a certification path rejected ?
            return CertificationPath.statuses[:awaiting_approval_after_appeal]
          end
        when CertificationPath.statuses[:awaiting_approval_after_appeal]
          # Only system_admin and project mngr can change status
          if can_leave_awaiting_approval_after_appeal_status?
            return CertificationPath.statuses[:awaiting_management_approvals]
          end
        when CertificationPath.statuses[:awaiting_management_approvals]
          # Only GORD mngr and GORD top mngr can change status
          if can_leave_awaiting_management_approvals_status?
            return CertificationPath.statuses[:certified]
          end
        when CertificationPath.statuses[:certified]
          # There is no next status
          throw(:error, 'There is no next status')
      end
    end
    return error
  end

  def previous_status
    # only system_admin can use this function
    # TODO provide code for previous_status
    raise NotImplementedError
  end

  private

  # Conditions are
  #  1) certification path is not expired
  #  2) certification path payment received
  #  3) project details are provided
  #  4) certifier mngr is assigned
  def can_leave_awaiting_activation_status?
    # TODO certification path expiry date
    # certifier mngr is assigned
    if project.certifier_manager_assigned?
      return true
    end
    throw(:error, 'A certifier manager must be assigned to the project first')
  end

  # Conditions are
  #  1) all criteria are completed (= when all linked requirements and submitted scores are provided and no more documents waiting for approval)
  def can_leave_awaiting_submission_status?
    scheme_mix_criteria.each do |criterion|
      # all criteria are completed
      unless criterion.complete?
        throw(:error, 'All criteria must have status complete')
      end
      # all submitted scores provided
      if criterion.submitted_score.blank?
        throw(:error, 'There are submitted scores missing')
      end
      # all linked requirements are provided
      if criterion.has_required_requirements?
        throw(:error, 'There are still requirements in status \'required\'')
      end
      # no more documents waiting for approval
      if criterion.has_documents_awaiting_approval?
        throw(:error, 'There are still documents awaiting approval')
      end
    end
    return true
  end

  # Conditions are
  #  1) all criteria are screened
  def can_leave_awaiting_screening_status?
    return true
  end

  # Conditions are
  #  1) all criteria are completed (= when all linked requirements and submitted scores are provided and no more documents waiting for approval)
  def can_leave_awaiting_submission_after_screening_status?
    scheme_mix_criteria.each do |criterion|
      # all criteria are completed
      unless criterion.complete?
        throw(:error, 'All criteria must have status complete')
      end
      # all submitted scores provided
      if criterion.submitted_score.blank?
        throw(:error, 'There are submitted scores missing')
      end
      # all linked requirements are provided
      if criterion.has_required_requirements?
        throw(:error, 'There are still requirements in status \'required\'')
      end
      # no more documents waiting for approval
      if criterion.has_documents_awaiting_approval?
        throw(:error, 'There are still documents awaiting approval')
      end
    end
    return true
  end

  # Conditions are
  #  1) PCR track payment received
  def can_leave_awaiting_pcr_payment_status?
    if pcr_track_allowed?
      return true
    end
    throw(:error, 'The PCR track allowed flag must be set first')
  end

  # Conditions are
  #  1) all criteria are reviewed
  def can_leave_awaiting_submission_after_pcr_status?
    return true
  end

  # Conditions are
  #  1) all criteria are verified (= when all achieved scores are provided)
  def can_leave_awaiting_verification_status?
    scheme_mix_criteria.each do |criterion|
      unless criterion.approved? || criterion.resubmit?
        throw(:error, 'There are still criteria in status \'complete\'')
      end
      if criterion.achieved_score.blank?
        throw(:error, 'There are achieved scores missing')
      end
    end
    return true
  end

  # Conditions are
  #  none
  def can_leave_awaiting_approval_or_appeal_status?
    return true
  end

  # Conditions are
  #  1) payment received
  def can_leave_awaiting_appeal_payment_status?
    return true
  end

  # Conditions are
  #  1) all appealed criteria are completed (= when all linked requirements and submitted scores are provided and no more documents waiting for approval)
  def can_leave_awaiting_submission_after_appeal_status?
    scheme_mix_criteria.each do |criterion|
      # all criteria are completed
      unless criterion.complete?
        throw(:error, 'All criteria must have status complete')
      end
      # all submitted scores provided
      if criterion.submitted_score.blank?
        throw(:error, 'There are submitted scores missing')
      end
      # all linked requirements are provided
      if criterion.has_required_requirements?
        throw(:error, 'There are still requirements in status \'required\'')
      end
      # no more documents waiting for approval
      if criterion.has_documents_awaiting_approval?
        throw(:error, 'There are still documents awaiting approval')
      end
    end
    return true
  end

  # Conditions are
  #  1) all criteria are verified (= when all achieved scores are provided)
  def can_leave_awaiting_verification_after_appeal_status?
    scheme_mix_criteria.each do |criterion|
      unless criterion.approved? || criterion.resubmit?
        throw(:error, 'There are still criteria in status \'complete\'')
      end
      if criterion.achieved_score.blank?
        throw(:error, 'There are achieved scores missing')
      end
    end
    return true
  end

  # Conditions are
  #  none
  def can_leave_awaiting_approval_after_appeal_status?
    return true
  end

  # Conditions are
  #  1) signed flag set for both GORD mngr and GORD top mngr
  def can_leave_awaiting_management_approvals_status?
    if signed_by_mngr? && signed_by_top_mngr?
      return true
    end
    throw(:error, 'Both signed by GORD manager and signed by GORD top manager must be set')
  end
end
