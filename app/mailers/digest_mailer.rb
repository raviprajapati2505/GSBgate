class DigestMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

  MAX_LOG_ITEMS = 10

  def digest_email(user)
    @user = user
    user.last_notified_at ||= DateTime.new

    if user.gord_manager? || user.gord_top_manager?
      # NO AUDIT LOG
      @audit_logs = []
      @more_audit_logs = 0
    else
      if user.system_admin? || user.gord_admin?
        @audit_logs = AuditLog.where('updated_at > ?', user.last_notified_at)
      else
      @audit_logs = AuditLog.where('updated_at > ?', user.last_notified_at)
                            .where('project_id IN (select projects_users.project_id from projects_users where projects_users.user_id = ?)', user.id)
      end

      exclude_notifications = NotificationTypesUser.where(user: user, notification_type_id: NotificationType::NEW_USER_COMMENT)
      if exclude_notifications.any?
        exclude_notifications.each do |exclude_notification|
          @audit_logs = @audit_logs.where.not(user_comment: nil, project_id: exclude_notification.project_id)
        end
      end

      exclude_notifications = NotificationTypesUser.where(user: user, notification_type_id: NotificationType::PROJECT_AUTHORIZATION_CHANGED)
      if exclude_notifications.any?
        @audit_logs = @audit_logs.where.not(auditable_type: ProjectsUser.name.demodulize)
      end
      exclude_notifications = NotificationTypesUser.where(user: user, notification_type_id: NotificationType::PROJECT_CREATED)
      if exclude_notifications.any?
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.system_message like \'%created.\'', Project.name.demodulize)
      end
      exclude_notifications = NotificationTypesUser.where(user: user, notification_type_id: NotificationType::PROJECT_UPDATED)
      if exclude_notifications.any?
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.system_message like \'%updated.\'', Project.name.demodulize)
      end
      exclude_notifications = NotificationTypesUser.where(user: user, notification_type_id: NotificationType::CERTIFICATE_PCR_REQUESTED)
      if exclude_notifications.any?
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.system_message like \'%issued%\'', CertificationPath.name.demodulize)
      end
      exclude_notifications = NotificationTypesUser.where(user: user, notification_type_id: NotificationType::CERTIFICATE_PCR_CANCELED)
      if exclude_notifications.any?
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.system_message like \'%canceled%\'', CertificationPath.name.demodulize)
      end
      exclude_notifications = NotificationTypesUser.where(user: user, notification_type_id: NotificationType::CERTIFICATE_PCR_APPROVED)
      if exclude_notifications.any?
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.system_message like \'%granted.\'', CertificationPath.name.demodulize)
      end
      exclude_notifications = NotificationTypesUser.where(user: user, notification_type_id: NotificationType::CERTIFICATE_PCR_REJECTED)
      if exclude_notifications.any?
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.system_message like \'%rejected.\'', CertificationPath.name.demodulize)
      end
      exclude_notifications = NotificationTypesUser.where(user: user, notification_type_id: NotificationType::CRITERION_ASSIGNMENT_CHANGED)
      if exclude_notifications.any?
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.system_message like \'%assigned%\'', SchemeMixCriterion.name.demodulize)
      end
      exclude_notifications = NotificationTypesUser.where(user: user, notification_type_id: NotificationType::CRITERION_SCORE_CHANGED)
      if exclude_notifications.any?
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.system_message like \'%score%\'', SchemeMixCriterion.name.demodulize)
      end
      exclude_notifications = NotificationTypesUser.where(user: user, notification_type_id: NotificationType::CRITERION_TEXT_CHANGED)
      if exclude_notifications.any?
        @audit_logs = @audit_logs.where.not(auditable_type: SchemeCriterionText.name.demodulize)
      end
      exclude_notifications = NotificationTypesUser.where(user: user, notification_type_id: NotificationType::REQUIREMENT_ASSIGNMENT_CHANGED)
      if exclude_notifications.any?
        @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.system_message like \'%assigned%\'', RequirementDatum.name.demodulize)
      end

      add_condition(user, NotificationType::CERTIFICATE_APPLIED, CertificationPath.name.demodulize, CertificationPathStatus::ACTIVATING)
      add_condition(user, NotificationType::CERTIFICATE_ACTIVATED, CertificationPath.name.demodulize, CertificationPathStatus::SUBMITTING)
      add_condition(user, NotificationType::CERTIFICATE_SUBMITTED_FOR_SCREENING, CertificationPath.name.demodulize, CertificationPathStatus::SCREENING)
      add_condition(user, NotificationType::CERTIFICATE_SCREENED, CertificationPath.name.demodulize, CertificationPathStatus::SUBMITTING_AFTER_SCREENING)
      add_condition(user, NotificationType::CERTIFICATE_PCR_SELECTED, CertificationPath.name.demodulize, CertificationPathStatus::PROCESSING_PCR_PAYMENT)
      add_condition(user, NotificationType::CERTIFICATE_PCR_APPROVED, CertificationPath.name.demodulize, CertificationPathStatus::SUBMITTING_PCR)
      add_condition(user, NotificationType::CERTIFICATE_SUBMITTED_FOR_VERIFICATION, CertificationPath.name.demodulize, CertificationPathStatus::VERIFYING)
      add_condition(user, NotificationType::CERTIFICATE_VERIFIED, CertificationPath.name.demodulize, CertificationPathStatus::ACKNOWLEDGING)
      add_condition(user, NotificationType::CERTIFICATE_APPEALED, CertificationPath.name.demodulize, CertificationPathStatus::PROCESSING_APPEAL_PAYMENT)
      add_condition(user, NotificationType::CERTIFICATE_APPEAL_APPROVED, CertificationPath.name.demodulize, CertificationPathStatus::SUBMITTING_AFTER_APPEAL)
      add_condition(user, NotificationType::CERTIFICATE_SUBMITTED_FOR_VERIFICATION_AFTER_APPEAL, CertificationPath.name.demodulize, CertificationPathStatus::VERIFYING_AFTER_APPEAL)
      add_condition(user, NotificationType::CERTIFICATE_VERIFIED_AFTER_APPEAL, CertificationPath.name.demodulize, CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL)
      add_condition(user, NotificationType::CERTIFICATE_APPROVED_BY_MNGT, CertificationPath.name.demodulize, CertificationPathStatus::APPROVING_BY_MANAGEMENT)
      add_condition(user, NotificationType::CERTIFICATE_APPROVED_BY_TOP_MNGT, CertificationPath.name.demodulize, CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT)
      add_condition(user, NotificationType::CERTIFICATE_ISSUED, CertificationPath.name.demodulize, CertificationPathStatus::CERTIFIED)
      add_condition(user, NotificationType::CERTIFICATE_REJECTED, CertificationPath.name.demodulize, CertificationPathStatus::NOT_CERTIFIED)
      add_condition(user, NotificationType::CRITERION_SUBMITTED, SchemeMixCriterion.name.demodulize, SchemeMixCriterion::statuses[:submitted])
      add_condition(user, NotificationType::CRITERION_VERIFIED, SchemeMixCriterion.name.demodulize, [SchemeMixCriterion::statuses[:submitted_score_achieved], SchemeMixCriterion::statuses[:submitted_score_not_achieved]])
      add_condition(user, NotificationType::CRITERION_APPEALED, SchemeMixCriterion.name.demodulize, SchemeMixCriterion::statuses[:appealed])
      add_condition(user, NotificationType::CRITERION_SUBMITTED_AFTER_APPEAL, SchemeMixCriterion.name.demodulize, SchemeMixCriterion::statuses[:submitted_after_appeal])
      add_condition(user, NotificationType::CRITERION_VERIFIED_AFTER_APPEAL, SchemeMixCriterion.name.demodulize, [SchemeMixCriterion::statuses[:submitted_score_achieved_after_appeal], SchemeMixCriterion::statuses[:submitted_score_not_achieved_after_appeal]])
      add_condition(user, NotificationType::CRITERION_OTHER_STATE_CHANGES, SchemeMixCriterion.name.demodulize, [SchemeMixCriterion::statuses[:submitting],SchemeMixCriterion::statuses[:verifying],SchemeMixCriterion::statuses[:submitting_after_appeal],SchemeMixCriterion::statuses[:verifying_after_appeal]])
      add_condition(user, NotificationType::REQUIREMENT_PROVIDED, RequirementDatum.name.demodulize, RequirementDatum::statuses[:provided])
      add_condition(user, NotificationType::REQUIREMENT_PROVIDED, RequirementDatum.name.demodulize, [RequirementDatum::statuses[:required],RequirementDatum::statuses[:not_required]])
      add_condition(user, NotificationType::NEW_DOCUMENT_WAITING_FOR_APPROVAL, SchemeMixCriteriaDocument.name.demodulize, SchemeMixCriteriaDocument::statuses[:awaiting_approval])
      add_condition(user, NotificationType::DOCUMENT_APPROVED, SchemeMixCriteriaDocument.name.demodulize, SchemeMixCriteriaDocument::statuses[:approved])
      add_condition(user, NotificationType::DOCUMENT_APPROVED, SchemeMixCriteriaDocument.name.demodulize, SchemeMixCriteriaDocument::statuses[:rejected])
      add_condition(user, NotificationType::DOCUMENT_APPROVED, SchemeMixCriteriaDocument.name.demodulize, SchemeMixCriteriaDocument::statuses[:superseded])

      @more_audit_logs = @audit_logs.count - MAX_LOG_ITEMS
      @more_audit_logs = @more_audit_logs < 0 ? 0 : @more_audit_logs

      @audit_logs = @audit_logs.limit(MAX_LOG_ITEMS)
    end

    exclude_new_tasks = NotificationTypesUser.where(user: user, notification_type_id: NotificationType::NEW_TASK)
    unless exclude_new_tasks.any?
      @include_new_tasks = true
      @more_tasks = TaskService::count_tasks(user: user, from_datetime: user.last_notified_at) - MAX_LOG_ITEMS
      @more_tasks = @more_tasks < 0 ? 0 : @more_tasks

      @tasks = TaskService::get_tasks(page: 1, per_page: MAX_LOG_ITEMS, user: user, from_datetime: user.last_notified_at)
    else
      @include_new_tasks = false
      @tasks = []
      @more_tasks = 0
    end

    mail(to: @user.email, subject: 'GSASgate - progress report') unless (@tasks.empty? && @audit_logs.empty?)

    user.last_notified_at = DateTime.current
    user.save!
  end

  def added_to_project_email(projectsuser)
    @user = projectsuser.user
    @project = projectsuser.project
    @role = projectsuser.role.humanize

    mail(to: @user.email, subject: "GSASgate - you are added to project #{@project.name}")
  end

  def updated_role_email(projectsuser)
    @user = projectsuser.user
    @project = projectsuser.project
    @role = projectsuser.role.humanize

    mail(to: @user.email, subject: "GSASgate - your role changed for project #{@project.name}")
  end

  def removed_from_project_email(projectsuser)
    @user = projectsuser.user
    @project = projectsuser.project

    mail(to: @user.email, subject: "GSASgate - you are removed from project #{@project.name}")
  end

  def project_registered_email(project)
    @project = project

    mail(to: Rails.configuration.x.gsas_info.email, subject: "GSASgate - new project #{@project.name} registered")
  end

  def certification_activated_email(certification_path)
    @certification_path = certification_path

    mail(to: Rails.configuration.x.gsas_info.email, subject: "GSASgate - certification #{@certification_path.name} for #{@certification_path.project.name} is activated")
  end

  def certification_expired_email(certification_path)
    @certification_path = certification_path

    mail(to: Rails.configuration.x.gsas_info.email, subject: "GSASgate - certification #{@certification_path.name} for #{@certification_path.project.name} is expired")
  end

  private

  def add_condition(user, notification_type, auditable_type, new_status)
    exclude_notifications = NotificationTypesUser.where(user: user, notification_type_id: notification_type)
    if exclude_notifications.any?
      exclude_notifications.each do |exclude_notification|
        if new_status.kind_of?(Array)
          @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status in (?) and project_id = ?', auditable_type, new_status, exclude_notification.project_id)
        else
          @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ? and project_id = ?', auditable_type, new_status, exclude_notification.project_id)
        end
      end
    end
  end
end