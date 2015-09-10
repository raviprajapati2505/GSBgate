class StateService
  include Singleton

  def current_state(certification_path: required)

  end

  def next_state(certification_path: required)
    case certification_path.status
      when CertificationPath.statuses[:registered]
        # Only system_admin can change state
        # Conditions are
        #  1) certification path is not expired
        #  2) certification path payment received
        #  3) project details are provided
        #  4) certifier mngr is assigned
      when CertificationPath.statuses[:in_submission]
        # Only system_admin and project mngr can change state
        # Conditions are
        #  1) all criteria are completed (= when all linked requirements and submitted scores are provided and no more documents waiting for approval)
      when CertificationPath.statuses[:in_screening]
        # Only system_admin and certifier mngr can change state
        # Conditions are
        #  1) all criteria are screened
      when CertificationPath.statuses[:screened]
        # Only system_admin and project mngr can change state
        # Conditions are
        #  1) all criteria are completed (= when all linked requirements and submitted scores are provided and no more documents waiting for approval)
        # The next state depends on the PCR track flag (awaiting_pcr_admittance or in_verification)
      when CertificationPath.statuses[:awaiting_pcr_admittance]
        # Only system_admin can change state
        # Conditions are
        #  1) PCR track payment received
      when CertificationPath.statuses[:in_review]
        # Only system_admin and certifier mngr can change state
        # Conditions are
        #  1) all criteria are reviewed (= when all achieved scores are provided)
      when CertificationPath.statuses[:reviewed]
        # Only system_admin and project mngr can change state
        # Conditions are
        #  1) all criteria are completed (= when all linked requirements and submitted scores are provided and no more documents waiting for approval)
      when CertificationPath.statuses[:in_verification]
        # Only system_admin and certifier mngr can change state
        # Conditions are
        #  1) all criteria are verified (= when all achieved scores are provided)
        # The next state depends on the outcome of the verification process (certification_rejected or awaiting_approval)
      when CertificationPath.statuses[:certification_rejected]
        # Only system_admin and project mngr can change state
        # Conditions are
        #  1) appealed for at least 1 criterion
      when CertificationPath.statuses[:awaiting_approval]
        # Only system_admin and project mngr can change state
        # Conditions are
        #  none
        # The next state depends if appealed for at least 1 criterion (awaiting_appeal_approval or awaiting_signatures)
      when CertificationPath.statuses[:awaiting_appeal_approval]
        # Only system_admin can change state
        # Conditions are
        #  1) payment received
      when CertificationPath.statuses[:in_submission_after_appeal]
        # Only system_admin and project mngr can change state
        # Conditions are
        #  1) all appealed criteria are completed (= when all linked requirements and submitted scores are provided and no more documents waiting for approval)
      when CertificationPath.statuses[:in_verification_after_appeal]
        # Only system_admin and certifier mngr can change state
        # Conditions are
        #  1) all criteria are verified (= when all achieved scores are provided)
        # The next state depends on the outcome of the verification process (certification_rejected_after_appeal or awaiting_approval_after_appeal)
      when CertificationPath.statuses[:certification_rejected_after_appeal]
        # Does this state exist ?
      when CertificationPath.statuses[:awaiting_approval_after_appeal]
        # Only system_admin and project mngr can change state
        # Conditions are
        #  none
      when CertificationPath.statuses[:awaiting_signatures]
        # Only GORD mngr and GORD top mngr can change state
        # Conditions are
        #  1) signed flag set for both GORD mngr and GORD top mngr
      when CertificationPath.statuses[:certified]
        # There is no next state
    end
  end

  def previous_state(certification_path: required)
    # only system_admin can use this function
    # TODO provide code for previous_state
  end

end