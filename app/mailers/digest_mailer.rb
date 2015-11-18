class DigestMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

  MAX_LOG_ITEMS = 10

  def digest_email(user)
    @user = user
    notification_types = user.notification_types.all.to_a
    @include_new_tasks = notification_types.any? {|type| type.notification_type_id == NotificationType::NEW_TASK}
    @include_user_comments = notification_types.any? {|type| type.notification_type_id == NotificationType::NEW_USER_COMMENT}
    @include_created_projects = notification_types.any? {|type| type.notification_type_id == NotificationType::PROJECT_CREATED}
    @include_applied_certificates = notification_types.any? {|type| type.notification_type_id == NotificationType::CERTIFICATE_APPLIED}
    @include_activated_certificates = notification_types.any? {|type| type.notification_type_id == NotificationType::CERTIFICATE_ACTIVATED}
    @include_submitted_certificates_screening = notification_types.any? {|type| type.notification_type_id == NotificationType::CERTIFICATE_SUBMITTED_FOR_SCREENING}
    @include_screened_certificates = notification_types.any? {|type| type.notification_type_id == NotificationType::CERTIFICATE_SCREENED}
    @include_pcr_selected = notification_types.any? {|type| type.notification_type_id == NotificationType::CERTIFICATE_PCR_SELECTED}
    @include_pcr_approved = notification_types.any? {|type| type.notification_type_id == NotificationType::CERTIFICATE_PCR_APPROVED}
    @include_submitted_certificates_verification = notification_types.any? {|type| type.notification_type_id == NotificationType::CERTIFICATE_SUBMITTED_FOR_VERIFICATION}
    @include_verified_certificates = notification_types.any? {|type| type.notification_type_id == NotificationType::CERTIFICATE_VERIFIED}
    @include_appealed_certificates = notification_types.any? {|type| type.notification_type_id == NotificationType::CERTIFICATE_APPEALED}
    @include_appeal_approved = notification_types.any? {|type| type.notification_type_id == NotificationType::CERTIFICATE_APPEAL_APPROVED}
    @include_submitted_appealed_certificates = notification_types.any? {|type| type.notification_type_id == NotificationType::CERTIFICATE_SUBMITTED_FOR_VERIFICATION_AFTER_APPEAL}
    @include_verified_appealed_certificates = notification_types.any? {|type| type.notification_type_id == NotificationType::CERTIFICATE_VERIFIED_AFTER_APPEAL}
    @include_approved_certificates = notification_types.any? {|type| type.notification_type_id == NotificationType::CERTIFICATE_APPROVED_BY_MNGT}
    @include_issued_certificates = notification_types.any? {|type| type.notification_type_id == NotificationType::CERTIFICATE_ISSUED}
    @include_submitted_criteria = notification_types.any? {|type| type.notification_type_id == NotificationType::CRITERION_SUBMITTED}
    @include_verified_criteria = notification_types.any? {|type| type.notification_type_id == NotificationType::CRITERION_VERIFIED}
    @include_appealed_criteria = notification_types.any? {|type| type.notification_type_id == NotificationType::CRITERION_APPEALED}
    @include_submitted_appealed_criteria = notification_types.any? {|type| type.notification_type_id = NotificationType::CRITERION_SUBMITTED_AFTER_APPEAL}
    @include_verified_appealed_criteria = notification_types.any? {|type| type.notification_type_id = NotificationType::CRITERION_VERIFIED_AFTER_APPEAL}
    @include_provided_requirements = notification_types.any? {|type| type.notification_type_id = NotificationType::REQUIREMENT_PROVIDED}
    @include_documents_waiting = notification_types.any? {|type| type.notification_type_id = NotificationType::NEW_DOCUMENT_WAITING_FOR_APPROVAL}
    @include_approved_documents = notification_types.any? {|type| type.notification_type_id = NotificationType::DOCUMENT_APPROVED}

    user.last_notified_at ||= DateTime.new

    if user.gord_manager? || user.gord_top_manager?
      # @audit_logs = AuditLog.where('updated_at > ?', Date.yesterday)
      # NO AUDIT LOG
      @audit_logs = []
      @more_audit_logs = 0
    else
      if user.system_admin?
        @audit_logs = AuditLog.where('updated_at > ?', user.last_notified_at)
      else
      @audit_logs = AuditLog.where('updated_at > ?', user.last_notified_at)
                            .where('project_id IN (select projects_users.project_id from projects_users where projects_users.user_id = ?)', user.id)
      end

      unless @include_user_comments
        @audit_logs = @audit_logs.where.not(user_comment: nil)
      end

      unless @include_created_projects
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.system_message like \'%created.\'', Project.name.demodulize)
      end

      unless @include_applied_certificates
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ?', CertificationPath.name.demodulize, CertificationPathStatus::ACTIVATING)
      end

      unless @include_activated_certificates
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ?', CertificationPath.name.demodulize, CertificationPathStatus::SUBMITTING)
      end

      unless @include_submitted_certificates_screening
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type= ? and audit_logs.new_status = ?', CertificationPath.name.demodulize, CertificationPathStatus::SCREENING)
      end

      unless @include_screened_certificates
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ?', CertificationPath.name.demodulize, CertificationPathStatus::SUBMITTING_AFTER_SCREENING)
      end

      unless @include_pcr_selected
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ?', CertificationPath.name.demodulize, CertificationPathStatus::PROCESSING_PCR_PAYMENT)
      end

      unless @include_pcr_approved
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type= ? and audit_logs.new_status = ?', CertificationPath.name.demodulize, CertificationPathStatus::SUBMITTING_PCR)
      end

      unless @include_submitted_certificates_verification
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ?', CertificationPath.name.demodulize, CertificationPathStatus::VERIFYING)
      end

      unless @include_verified_certificates
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ?', CertificationPath.name.demodulize, CertificationPathStatus::ACKNOWLEDGING)
      end

      unless @include_appealed_certificates
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ?', CertificationPath.name.demodulize, CertificationPathStatus::PROCESSING_APPEAL_PAYMENT)
      end

      unless @include_appeal_approved
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ?', CertificationPath.name.demodulize, CertificationPathStatus::SUBMITTING_AFTER_APPEAL)
      end

      unless @include_submitted_appealed_certificates
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ?', CertificationPath.name.demodulize, CertificationPathStatus::VERIFYING_AFTER_APPEAL)
      end

      unless @include_verified_appealed_certificates
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ?', CertificationPath.name.demodulize, CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL)
      end

      unless @include_approved_certificates
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ?', CertificationPath.name.demodulize, CertificationPathStatus::APPROVING_BY_MANAGEMENT)
      end

      unless @include_issued_certificates
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ?', CertificationPath.name.demodulize, CertificationPathStatus::CERTIFIED)
      end

      unless @include_submitted_criteria
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ?', SchemeMixCriterion.name.demodulize, SchemeMixCriterion::statuses[:submitted])
      end

      unless @include_verified_criteria
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status in (?,?)', SchemeMixCriterion.name.demodulize, SchemeMixCriterion::statuses[:target_achieved], SchemeMixCriterion::statuses[:target_not_achieved])
      end

      unless @include_appealed_criteria
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ?', SchemeMixCriterion.name.demodulize, SchemeMixCriterion::statuses[:appealed])
      end

      unless @include_submitted_appealed_criteria
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ?', SchemeMixCriterion.name.demodulize, SchemeMixCriterion::statuses[:submitted_after_appeal])
      end

      unless @include_verified_appealed_criteria
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status in (?,?)', SchemeMixCriterion.name.demodulize, SchemeMixCriterion::statuses[:target_achieved_after_appeal], SchemeMixCriterion::statuses[:target_not_achieved_after_appeal])
      end

      unless @include_provided_requirements
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ?', RequirementDatum.name.demodulize, RequirementDatum::statuses[:provided])
      end

      unless @include_documents_waiting
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ?', SchemeMixCriteriaDocument.name.demodulize, SchemeMixCriteriaDocument::statuses[:awaiting_approval])
      end

      unless @include_approved_documents
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ?', SchemeMixCriteriaDocument.name.demodulize, SchemeMixCriteriaDocument::statuses[:approved])
      end

      @more_audit_logs = @audit_logs.count - MAX_LOG_ITEMS
      @more_audit_logs = @more_audit_logs < 0 ? 0 : @more_audit_logs

      @audit_logs = @audit_logs.limit(MAX_LOG_ITEMS)
    end

    if @include_new_tasks
      @more_tasks = TaskService::count_tasks(user: user, from_datetime: user.last_notified_at) - MAX_LOG_ITEMS
      @more_tasks = @more_tasks < 0 ? 0 : @more_tasks

      @tasks = TaskService::get_tasks(page: 1, per_page: MAX_LOG_ITEMS, user: user, from_datetime: user.last_notified_at)
    else
      @tasks = []
      @more_tasks = 0
    end

    mail(to: @user.email, subject: 'GSAS : progress report') unless (@tasks.empty? && @audit_logs.empty?)

    user.last_notified_at = DateTime.current
    user.save!
  end

  def added_to_project_email(projectsuser)
    @user = projectsuser.user
    @project = projectsuser.project
    @role = projectsuser.role.humanize

    mail(to: @user.email, subject: "GSAS : you are added to project #{@project.name}")
  end

  def updated_role_email(projectsuser)
    @user = projectsuser.user
    @project = projectsuser.project
    @role = projectsuser.role.humanize

    mail(to: @user.email, subject: "GSAS : your role changed for project #{@project.name}")
  end

  def removed_from_project_email(projectsuser)
    @user = projectsuser.user
    @project = projectsuser.project

    mail(to: @user.email, subject: "GSAS : you are removed from project #{@project.name}")
  end
end