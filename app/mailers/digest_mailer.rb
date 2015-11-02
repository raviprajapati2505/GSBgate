class DigestMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

  MAX_LOG_ITEMS = 10

  def digest_email(user)
    @user = user

    if user.system_admin? || user.gord_manager? || user.gord_top_manager?
      @audit_logs = AuditLog.where('updated_at > ?', Date.yesterday)
    else
      @audit_logs = AuditLog.where('updated_at > ?', Date.yesterday)
                            .where('project_id IN (select projects_users.project_id from projects_users where projects_users.user_id = ?)', user.id)
    end
    @more_audit_logs = @audit_logs.count - MAX_LOG_ITEMS
    @more_audit_logs = @more_audit_logs < 0 ? 0 : @more_audit_logs

    @more_tasks = TaskService::count_tasks(user: user) - MAX_LOG_ITEMS
    @more_tasks = @more_tasks < 0 ? 0 : @more_tasks

    @audit_logs = @audit_logs.limit(MAX_LOG_ITEMS)
    @tasks = TaskService::get_tasks(page: 1, per_page: MAX_LOG_ITEMS, user: user)
    mail(to: @user.email, subject: 'GSAS : progress report') unless (@tasks.empty? && @audit_logs.empty?)
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