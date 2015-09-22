class TaskMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

  def tasks_email(user, tasks)
    @user = user
    @tasks = tasks
    mail(to: @user.email, subject: 'GSAS : progress report') unless @tasks.empty?
  end
end