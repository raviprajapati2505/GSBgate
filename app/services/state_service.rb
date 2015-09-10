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
      when CertificationPath.statuses[:registered]
        # Only system_admin can change state
        if can_leave_registered_state?(certification_path)
          return CertificationPath.statuses[:in_submission]
        end
      when CertificationPath.statuses[:in_submission]
        # Only system_admin and project mngr can change state
        if can_leave_in_submission_state?(certification_path)
          return CertificationPath.statuses[:in_screening]
        end
      when CertificationPath.statuses[:in_screening]
        # Only system_admin and certifier mngr can change state
        if can_leave_in_screening_state?(certification_path)
          return CertificationPath.statuses[:screened]
        end
      when CertificationPath.statuses[:screened]
        # Only system_admin and project mngr can change state
        if can_leave_screened_state?(certification_path)
          # The next state depends on the PCR track flag (awaiting_pcr_admittance or in_verification)
          if certification_path.pcr_track?
            return CertificationPath.statuses[:awaiting_pcr_admittance]
          else
            return CertificationPath.statuses[:in_verification]
          end
        end
      when CertificationPath.statuses[:awaiting_pcr_admittance]
        # Only system_admin can change state
        if can_leave_awaiting_pcr_admittance_state?(certification_path)
          return CertificationPath.statuses[:in_review]
        end
      when CertificationPath.statuses[:in_review]
        # Only system_admin and certifier mngr can change state
        if can_leave_in_review_state?(certification_path)
          return CertificationPath.statuses[:reviewed]
        end
      when CertificationPath.statuses[:reviewed]
        # Only system_admin and project mngr can change state
        if can_leave_reviewed_state?(certification_path)
          return CertificationPath.statuses[:in_verification]
        end
      when CertificationPath.statuses[:in_verification]
        # Only system_admin and certifier mngr can change state
        if can_leave_in_verification_state?(certification_path)
          # The next state depends on the outcome of the verification process (certification_rejected or awaiting_approval)
          # TODO when is a certification path rejected ?
          # return CertificationPath.statuses[:certification_rejected]
          return CertificationPath.statuses[:awaiting_approval]
        end
      when CertificationPath.statuses[:certification_rejected]
        # Only system_admin and project mngr can change state
        if can_leave_certification_rejected_state?(certification_path)
          return CertificationPath.statuses[:awaiting_appeal_approval]
        end
      when CertificationPath.statuses[:awaiting_approval]
        # Only system_admin and project mngr can change state
        if can_leave_awaiting_approval_state?(certification_path)
          # The next state depends if appealed for at least 1 criterion (awaiting_appeal_approval or awaiting_signatures)
          # TODO implement appeal
          raise NotImplementedError
        end
      when CertificationPath.statuses[:awaiting_appeal_approval]
        # Only system_admin can change state
        if can_leave_awaiting_appeal_approval_state?(certification_path)
          return CertificationPath.statuses[:in_submission_after_appeal]
        end
      when CertificationPath.statuses[:in_submission_after_appeal]
        # Only system_admin and project mngr can change state
        if can_leave_in_submission_after_appeal_state?(certification_path)
          return CertificationPath.statuses[:in_verification_after_appeal]
        end
      when CertificationPath.statuses[:in_verification_after_appeal]
        # Only system_admin and certifier mngr can change state
        if can_leave_in_verification_after_appeal_state?(certification_path)
          # The next state depends on the outcome of the verification process (certification_rejected_after_appeal or awaiting_approval_after_appeal)
          # TODO when is a certification path rejected ?
          # return CertificationPath.statuses[:certification_rejected_after_appeal]
          return CertificationPath.statuses[:awaiting_approval_after_appeal]
        end
      when CertificationPath.statuses[:certification_rejected_after_appeal]
        # TODO Does this state exist ?
      when CertificationPath.statuses[:awaiting_approval_after_appeal]
        # Only system_admin and project mngr can change state
        if can_leave_awaiting_approval_after_appeal_state?(certification_path)
          return CertificationPath.statuses[:awaiting_signatures]
        end
      when CertificationPath.statuses[:awaiting_signatures]
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
  def can_leave_registered_state?(certification_path: required)
    # TODO certification path expiry date
    # certifier mngr is assigned
    if certification_path.project.certifier_manager_assigned?
      return true
    end
    return false
  end

  # Conditions are
  #  1) all criteria are completed (= when all linked requirements and submitted scores are provided and no more documents waiting for approval)
  def can_leave_in_submission_state?(certification_path: required)
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
  def can_leave_in_screening_state?(certification_path: required)
    certification_path.scheme_mix_criteria.each do |criterion|
      unless criterion.screened?
        return false
      end
    end
    return true
  end

  # Conditions are
  #  1) all criteria are completed (= when all linked requirements and submitted scores are provided and no more documents waiting for approval)
  def can_leave_screened_state?(certification_path: required)
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
  def can_leave_awaiting_pcr_admittance_state?(certification_path: required)
    if certification_path.pcr_track_allowed?
      return true
    end
    return false
  end

  # Conditions are
  #  1) all criteria are reviewed (= when all achieved scores are provided)
  def can_leave_in_review_state?(certification_path: required)
    certification_path.scheme_mix_criteria.each do |criterion|
      unless criterion.reviewed_approved? || criterion.resubmit?
        return false
      end
      if criterion.achieved_score.blank?
        return false
      end
    end
    return true
  end

  # Conditions are
  #  1) all criteria are completed (= when all linked requirements and submitted scores are provided and no more documents waiting for approval)
  def can_leave_reviewed_state?(certification_path: required)
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
  def can_leave_in_verification_state?(certification_path: required)
    certification_path.scheme_mix_criteria.each do |criterion|
      unless criterion.verified_approved? || criterion.disapproved?
        return false
      end
      if criterion.achieved_score.blank?
        return false
      end
    end
    return true
  end

  # Conditions are
  #  1) appealed for at least 1 criterion
  def can_leave_certification_rejected_state?(certification_path: required)
    # TODO implement appeal
    raise NotImplementedError
  end

  # Conditions are
  #  none
  def can_leave_awaiting_approval_state?(certification_path: required)
    return true
  end

  # Conditions are
  #  1) payment received
  def can_leave_awaiting_appeal_approval_state?(certification_path: required)
    return true
  end

  # Conditions are
  #  1) all appealed criteria are completed (= when all linked requirements and submitted scores are provided and no more documents waiting for approval)
  def can_leave_in_submission_after_appeal_state?(certification_path: required)
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
  def can_leave_in_verification_after_appeal_state?(certification_path: required)
    certification_path.scheme_mix_criteria.each do |criterion|
      unless criterion.verified_approved? || criterion.disapproved?
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
  def can_leave_awaiting_signatures_state?(certification_path: required)
    if certification_path.signed_by_mngr? && certification_path.signed_by_top_mngr?
      return true
    end
    return false
  end

end