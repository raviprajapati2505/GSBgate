class DigestMailer < ApplicationMailer
  include ActionView::Helpers::TranslationHelper
  add_template_helper(ApplicationHelper)

  MAX_LOG_ITEMS = 10

  def digest_email(user)
    @user = user
    user.last_notified_at ||= DateTime.new

    if user.gsas_trust_manager? || user.gsas_trust_top_manager?
      # NO AUDIT LOG
      @audit_logs = []
      @more_audit_logs = 0
    else
      if user.system_admin? || user.gsas_trust_admin?
        @audit_logs = AuditLog.where('updated_at > ?', user.last_notified_at)
      else
        audit_log = AuditLog.arel_table
        project = Project.arel_table
        projects_user = ProjectsUser.arel_table
        project_join_on = audit_log.create_on(audit_log[:project_id].eq(project[:id]))
        project_inner_join = audit_log.create_join(project, project_join_on, Arel::Nodes::InnerJoin)
        projects_user_join_on = project.create_on(project[:id].eq(projects_user[:project_id]))
        projects_user_outer_join = project.create_join(projects_user, projects_user_join_on, Arel::Nodes::OuterJoin)
        @audit_logs = AuditLog.joins(project_inner_join)
                          .joins(projects_user_outer_join)
                          .where(audit_log[:updated_at].gt(user.last_notified_at)
                                     .and(audit_log[:project_id].in(ProjectsUser.where(user_id: user.id).pluck(:project_id)))
                                     .and(audit_log[:audit_log_visibility_id].eq(AuditLogVisibility::PUBLIC).or(projects_user[:user_id].eq(user.id).and(projects_user[:role].in([ProjectsUser.roles[:certification_manager], ProjectsUser.roles[:certifier]]))))
                          ).distinct
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
      add_condition(user, NotificationType::CRITERION_VERIFIED, SchemeMixCriterion.name.demodulize, [SchemeMixCriterion::statuses[:score_awarded], SchemeMixCriterion::statuses[:score_downgraded], SchemeMixCriterion::statuses[:score_upgraded], SchemeMixCriterion::statuses[:score_minimal]])
      add_condition(user, NotificationType::CRITERION_APPEALED, SchemeMixCriterion.name.demodulize, SchemeMixCriterion::statuses[:appealed])
      add_condition(user, NotificationType::CRITERION_SUBMITTED_AFTER_APPEAL, SchemeMixCriterion.name.demodulize, SchemeMixCriterion::statuses[:submitted_after_appeal])
      add_condition(user, NotificationType::CRITERION_VERIFIED_AFTER_APPEAL, SchemeMixCriterion.name.demodulize, [SchemeMixCriterion::statuses[:score_awarded_after_appeal], SchemeMixCriterion::statuses[:score_downgraded_after_appeal], SchemeMixCriterion::statuses[:score_upgraded_after_appeal], SchemeMixCriterion::statuses[:score_minimal_after_appeal]])
      add_condition(user, NotificationType::CRITERION_OTHER_STATE_CHANGES, SchemeMixCriterion.name.demodulize, [SchemeMixCriterion::statuses[:submitting],SchemeMixCriterion::statuses[:verifying],SchemeMixCriterion::statuses[:submitting_after_appeal],SchemeMixCriterion::statuses[:verifying_after_appeal]])
      add_condition(user, NotificationType::REQUIREMENT_PROVIDED, RequirementDatum.name.demodulize, RequirementDatum::statuses[:provided])
      add_condition(user, NotificationType::REQUIREMENT_PROVIDED, RequirementDatum.name.demodulize, [RequirementDatum::statuses[:required],RequirementDatum::statuses[:not_required]])
      add_condition(user, NotificationType::NEW_DOCUMENT_WAITING_FOR_APPROVAL, SchemeMixCriteriaDocument.name.demodulize, SchemeMixCriteriaDocument::statuses[:awaiting_approval])
      add_condition(user, NotificationType::DOCUMENT_APPROVED, SchemeMixCriteriaDocument.name.demodulize, SchemeMixCriteriaDocument::statuses[:approved])
      add_condition(user, NotificationType::DOCUMENT_APPROVED, SchemeMixCriteriaDocument.name.demodulize, SchemeMixCriteriaDocument::statuses[:rejected])

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

    if @user.gsas_trust_top_manager?
      subject = 'Tasks for approval for Chairman (Dr. Yousef)'
    elsif @user.gsas_trust_manager?
      subject = 'Tasks for approval for Head of GSAS'
    else
      subject = 'GSASgate - progress report'
    end
    mail(to: @user.email, subject: subject) unless (@tasks.empty? && @audit_logs.empty?)

    user.last_notified_at = DateTime.current
    user.save!
  end

  def added_to_project_email(projectsuser, invited_by)
    @user = projectsuser.user
    @project = projectsuser.project
    @role = t(projectsuser.role, scope: 'activerecord.attributes.projects_user.roles')
    @invited_by = invited_by

    mail(to: @user.email, subject: "GSASgate - you are added to project #{@project.name}")
  end

  def updated_role_email(projectsuser)
    @user = projectsuser.user
    @project = projectsuser.project
    @role = t(projectsuser.role, scope: 'activerecord.attributes.projects_user.roles')

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

  def applied_for_certification(certification_path)
    @certification_path = certification_path

    mail(to: Rails.configuration.x.gsas_info.email, subject: "GSASgate - new certification #{@certification_path.name} applied for")
  end

  def certificate_approved_email(certification_path)
    @certification_path = certification_path
    emails = []
    emails << User.find_by(role: "gsas_trust_manager").email #Head of gsas trust
    emails << ProjectsUser.where(project_id: @certification_path.project_id).find_by(role: "certification_manager").user.email  #Certification manager
    emails << ProjectsUser.where(project_id: @certification_path.project_id).find_by(role: "cgp_project_manager").user.email #CGP project manager
    emails << ProjectsUser.where(project_id: @certification_path.project_id).find_by(role: "enterprise_client")&.user&.email #Enterprice Client
    emails << User.where(role: "document_controller").pluck(:email) #Document controlller
    mail(to: emails, subject: "GSASgate - certification #{@certification_path.name} approved")
  end

  def certification_activated_email(certification_path)
    @certification_path = certification_path

    mail(to: Rails.configuration.x.gsas_info.email, subject: "GSASgate - certification #{@certification_path.name} for #{@certification_path.project.name} is activated")
  end

  def certification_expired_email(certification_path)
    @certification_path = certification_path

    mail(to: Rails.configuration.x.gsas_info.email, subject: "GSASgate - certification #{@certification_path.name} for #{@certification_path.project.name} is expired")
  end

  def certification_expires_in_near_future_email(certification_path)
    @certification_path = certification_path

    User.with_cgp_project_manager_role_for_project(@certification_path.project).each do |user|
      mail(to: user.email, subject: "GSASgate - certification #{@certification_path.name} for #{@certification_path.project.name} is going to expire on #{@certification_path.expires_at.strftime(t('date.formats.short'))}")
    end
  end

  def criteria_appealed_email(certification_path)
    @certification_path = certification_path
    @appealed_criteria = @certification_path.scheme_mix_criteria.where(status: [SchemeMixCriterion.statuses[:submitting_after_appeal]])

    mail(to: Rails.configuration.x.gsas_info.email, subject: "GSASgate - certification #{@certification_path.name} for #{certification_path.project.name} has appealed criteria")
  end

  def linkme_invitation_email(email, user, project)
    @user = user
    @project = project

    mail(to: email, subject: 'GSASgate - linkme.qa invitation')
  end

  def archive_created_email(archive)
    @archive = archive

    mail(to: "akash.p@bacancytechnology.com", subject: 'GSASgate - your archive was generated')
  end

  private

  def add_condition(user, notification_type, auditable_type, new_status)
    exclude_notifications = NotificationTypesUser.where(user: user, notification_type_id: notification_type)
    if exclude_notifications.any?
      exclude_notifications.each do |exclude_notification|
        if new_status.kind_of?(Array)
          @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status in (?) and audit_logs.project_id = ?', auditable_type, new_status, exclude_notification.project_id)
        else
          @audit_logs = @audit_logs.where.not('audit_logs.auditable_type = ? and audit_logs.new_status = ? and audit_logs.project_id = ?', auditable_type, new_status, exclude_notification.project_id)
        end
      end
    end
  end
end