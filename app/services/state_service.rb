class StateService
  include Singleton

  def current_state(certification_path: required)
    # TODO provide code for current_state
    raise NotImplementedError
  end

  # returns false if not all conditions are met to advance to the next state
  # returns one of CertificationPath.statuses otherwise
  def next_state(certification_path: required)
    case certification_path.status
      when CertificationPath.statuses[:awaiting_activation]
        # Only system_admin can change state
        if can_leave_awaiting_activation_state?(certification_path)
          return CertificationPath.statuses[:awaiting_submission]
        end
      when CertificationPath.statuses[:awaiting_submission]
        # Only system_admin and project mngr can change state
        if can_leave_awaiting_submission_state?(certification_path)
          return CertificationPath.statuses[:awaiting_screening]
        end
      when CertificationPath.statuses[:awaiting_screening]
        # Only system_admin and certifier mngr can change state
        if can_leave_awaiting_screening_state?(certification_path)
          return CertificationPath.statuses[:awaiting_submission_after_screening]
        end
      when CertificationPath.statuses[:awaiting_submission_after_screening]
        # Only system_admin and project mngr can change state
        if can_leave_awaiting_submission_after_screening_state?(certification_path)
          # The next state depends on the PCR track flag
          if certification_path.pcr_track?
            return CertificationPath.statuses[:awaiting_pcr_payment]
          else
            return CertificationPath.statuses[:awaiting_verification]
          end
        end
      when CertificationPath.statuses[:awaiting_pcr_payment]
        # Only system_admin can change state
        if can_leave_awaiting_pcr_payment_state?(certification_path)
          return CertificationPath.statuses[:awaiting_submission_after_pcr]
        end
      when CertificationPath.statuses[:awaiting_submission_after_pcr]
        # Only system_admin, certifier mngr and project mngr can change state
        if can_leave_awaiting_submission_after_pcr_state?(certification_path)
          return CertificationPath.statuses[:awaiting_verification]
        end
      when CertificationPath.statuses[:awaiting_verification]
        # Only system_admin and certifier mngr can change state
        if can_leave_awaiting_verification_state?(certification_path)
          # The next state depends on the outcome of the verification process
          # TODO when is a certification path rejected ?
          return CertificationPath.statuses[:awaiting_approval_or_appeal]
        end
      when CertificationPath.statuses[:awaiting_approval_or_appeal]
        # Only system_admin and project mngr can change state
        if can_leave_awaiting_approval_or_appeal_state?(certification_path)
          # The next state depends if appealed for at least 1 criterion
          # TODO implement appeal
          return CertificationPath.statuses[:awaiting_management_approvals]
        end
      when CertificationPath.statuses[:awaiting_appeal_payment]
        # Only system_admin can change state
        if can_leave_awaiting_appeal_payment_state?(certification_path)
          return CertificationPath.statuses[:awaiting_submission_after_appeal]
        end
      when CertificationPath.statuses[:awaiting_submission_after_appeal]
        # Only system_admin and project mngr can change state
        if can_leave_awaiting_submission_after_appeal_state?(certification_path)
          return CertificationPath.statuses[:awaiting_verification_after_appeal]
        end
      when CertificationPath.statuses[:awaiting_verification_after_appeal]
        # Only system_admin and certifier mngr can change state
        if can_leave_awaiting_verification_after_appeal_state?(certification_path)
          # The next state depends on the outcome of the verification process
          # TODO when is a certification path rejected ?
          return CertificationPath.statuses[:awaiting_approval_after_appeal]
        end
      when CertificationPath.statuses[:awaiting_approval_after_appeal]
        # Only system_admin and project mngr can change state
        if can_leave_awaiting_approval_after_appeal_state?(certification_path)
          return CertificationPath.statuses[:awaiting_management_approvals]
        end
      when CertificationPath.statuses[:awaiting_management_approvals]
        # Only GORD mngr and GORD top mngr can change state
        if can_leave_awaiting_signatures_state?(certification_path)
          return CertificationPath.statuses[:certified]
        end
      when CertificationPath.statuses[:certified]
        # There is no next state
    end
    return false
  end

  def previous_state(certification_path: required)
    # only system_admin can use this function
    # TODO provide code for previous_state
    raise NotImplementedError
  end

  private

  # Conditions are
  #  1) certification path is not expired
  #  2) certification path payment received
  #  3) project details are provided
  #  4) certifier mngr is assigned
  def can_leave_awaiting_activation_state?(certification_path: required)
    # TODO certification path expiry date
    # certifier mngr is assigned
    if certification_path.project.certifier_manager_assigned?
      return true
    end
    return false
  end

  # Conditions are
  #  1) all criteria are completed (= when all linked requirements and submitted scores are provided and no more documents waiting for approval)
  def can_leave_awaiting_submission_state?(certification_path: required)
    certification_path.scheme_mix_criteria.each do |criterion|
      # all criteria are completed
      unless criterion.complete?
        return false
      end
      # all submitted scores provided
      if criterion.submitted_score.blank?
        return false
      end
      # all linked requirements are provided
      if criterion.has_required_requirements?
        return false
      end
      # no more documents waiting for approval
      if criterion.has_documents_awaiting_approval?
        return false
      end
    end
    return true
  end

  # Conditions are
  #  1) all criteria are screened
  def can_leave_awaiting_screening_state?(certification_path: required)
    return true
  end

  # Conditions are
  #  1) all criteria are completed (= when all linked requirements and submitted scores are provided and no more documents waiting for approval)
  def can_leave_awaiting_submission_after_screening_state?(certification_path: required)
    certification_path.scheme_mix_criteria.each do |criterion|
      # all criteria are completed
      unless criterion.complete?
        return false
      end
      # all submitted scores provided
      if criterion.submitted_score.blank?
        return false
      end
      # all linked requirements are provided
      if criterion.has_required_requirements?
        return false
      end
      # no more documents waiting for approval
      if criterion.has_documents_awaiting_approval?
        return false
      end
    end
    return true
  end

  # Conditions are
  #  1) PCR track payment received
  def can_leave_awaiting_pcr_payment_state?(certification_path: required)
    if certification_path.pcr_track_allowed?
      return true
    end
    return false
  end

  # Conditions are
  #  1) all criteria are reviewed
  def can_leave_awaiting_submission_after_pcr_state?(certification_path: required)
    return true
  end

  # Conditions are
  #  1) all criteria are verified (= when all achieved scores are provided)
  def can_leave_awaiting_verification_state?(certification_path: required)
    certification_path.scheme_mix_criteria.each do |criterion|
      unless criterion.approved? || criterion.resubmit?
        return false
      end
      if criterion.achieved_score.blank?
        return false
      end
    end
    return true
  end

  # Conditions are
  #  none
  def can_leave_awaiting_approval_or_appeal_state?(certification_path: required)
    return true
  end

  # Conditions are
  #  1) payment received
  def can_leave_awaiting_appeal_payment_state?(certification_path: required)
    return true
  end

  # Conditions are
  #  1) all appealed criteria are completed (= when all linked requirements and submitted scores are provided and no more documents waiting for approval)
  def can_leave_awaiting_submission_after_appeal_state?(certification_path: required)
    certification_path.scheme_mix_criteria.each do |criterion|
      # all criteria are completed
      unless criterion.complete?
        return false
      end
      # all submitted scores provided
      if criterion.submitted_score.blank?
        return false
      end
      # all linked requirements are provided
      if criterion.has_required_requirements?
        return false
      end
      # no more documents waiting for approval
      if criterion.has_documents_awaiting_approval?
        return false
      end
    end
    return true
  end

  # Conditions are
  #  1) all criteria are verified (= when all achieved scores are provided)
  def can_leave_awaiting_verification_after_appeal_state?(certification_path: required)
    certification_path.scheme_mix_criteria.each do |criterion|
      unless criterion.approved? || criterion.resubmit?
        return false
      end
      if criterion.achieved_score.blank?
        return false
      end
    end
    return true
  end

  # Conditions are
  #  none
  def can_leave_awaiting_approval_after_appeal_state?(certification_path: required)
    return true
  end

  # Conditions are
  #  1) signed flag set for both GORD mngr and GORD top mngr
  def can_leave_awaiting_management_approvals_state?(certification_path: required)
    if certification_path.signed_by_mngr? && certification_path.signed_by_top_mngr?
      return true
    end
    return false
  end

end