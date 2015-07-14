desc 'Notify users about approaching tasks due dates'
task :notifyTaskDueDate => :environment do

  # get all requirements with due date within 7 days
  notify('Requirement \'%s\' should be completed within %d days.', 7)

  # get all requirements with due date reached
  notify('Requirement \'%s\' should be completed within %d days.', 0)

  # get all scheme mix criteria with due date within 7 days
  notifyCertifier('Criterion \'%s\' should be completed within %d days.', 7)

  # get all scheme mix criteria with due date reached
  notifyCertifier('Criterion \'%s\' should be completed within %d days.', 0)

end

def notify(message, days_before_due_date)
  due_date = I18n.l(Date.today - days_before_due_date, format: '%Y-%m-%d')
  Rails.logger.info 'Start collecting requirements with due date = ' + due_date
  notification_count = 0
  page_size = 100
  page = 0
  begin
    page += 1
    requirement_data = RequirementDatum.where('status = 0 and due_date = ?', due_date).paginate page: page, per_page: page_size
    if requirement_data.size == 0
      next;
    end
    # create a notification per requirement
    requirement_data.each do |requirement_datum|
      scheme_mix_criterion = requirement_datum.scheme_mix_criteria.first
      scheme_mix = scheme_mix_criterion.scheme_mix
      certification_path = scheme_mix.certification_path
      project = certification_path.project
      Notification.create(body: sprintf(message, requirement_datum.requirement.label, days_before_due_date), uri: Rails.application.routes.url_helpers.project_certification_path_scheme_mix_scheme_mix_criterion_path(project.id, certification_path.id, scheme_mix.id, scheme_mix_criterion.id), user: requirement_datum.user)
    end
    notification_count += requirement_data.size
  end while requirement_data.size == page_size
  Rails.logger.info "Created #{notification_count} notifications for requirements #{days_before_due_date} before due date."
end

def notifyCertifier(message, days_before_due_date)
  due_date = I18n.l(Date.today - days_before_due_date, format: '%Y-%m-%d')
  Rails.logger.info 'Start collecting criteria with due date = ' + due_date
  notification_count = 0
  page_size = 100
  page = 0
  begin
    page += 1
    scheme_mix_criteria = SchemeMixCriterion.where('status <> 2 and status <> 3 and due_date = ?', due_date).paginate page: page, per_page: page_size
    if scheme_mix_criteria.size == 0
      next;
    end
    # create a notification per criterion
    scheme_mix_criteria.each do |scheme_mix_criterion|
      scheme_mix = scheme_mix_criterion.scheme_mix
      certification_path = scheme_mix.certification_path
      project = certification_path.project
      Notification.create(body: sprintf(message, scheme_mix_criterion.scheme_criterion.criterion.name, days_before_due_date), uri: Rails.application.routes.url_helpers.project_certification_path_scheme_mix_scheme_mix_criterion_path(project.id, certification_path.id, scheme_mix.id, scheme_mix_criterion.id), user: scheme_mix_criterion.certifier)
    end
    notification_count += scheme_mix_criteria.size
  end while scheme_mix_criteria.size == page_size
  Rails.logger.info "Created #{notification_count} notifications for scheme mix criteria #{days_before_due_date} before due date."
end