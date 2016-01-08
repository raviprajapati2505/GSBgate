namespace :gsas do

  PAGE_SIZE = 100

  # usage example: rake gsas:send_digest_mail[<user_email>]
  desc "Send email to users with a digest of their most recent project changes and their list of unfinished tasks"
  task :send_digest_mail, [:user_email] => :environment do |t, args|

    Rails.logger.info 'Start sending emails...'

    user_count = 0
    if args.user_email.present?
      user = User.find_by_email(args.user_email)
      if user.present?
        DigestMailer.digest_email(user).deliver_now
        user_count += 1
      end
    else
      page = 0
      begin
        page += 1
        users = User.all.page(page).per(PAGE_SIZE)
        users.each do |user|
          DigestMailer.digest_email(user).deliver_now
        end
        user_count += users.size
      end while users.size == PAGE_SIZE
    end

    Rails.logger.info "Processed #{ActionController::Base.helpers.pluralize(user_count, 'user')}."
  end

  desc "Create a task for the system admin for every certification path with maximum duration exceeded"
  task :create_duration_task, [] => :environment do |t, args|

    Rails.logger.info 'Start creating tasks for certification paths with maximum duration exceeded...'

    certification_path_count = 0
    page = 0
    begin
      page += 1
      certification_paths = CertificationPath
                                .where.not(certification_path_status_id: [CertificationPathStatus::CERTIFIED, CertificationPathStatus::NOT_CERTIFIED])
                                .where('(started_at + interval \'1\' year * duration) < ?', DateTime.now)
                                .page(page).per(PAGE_SIZE)
      certification_paths.each do |certification_path|
        CertificationPathTask.create(task_description_id: Taskable::SYS_ADMIN_DURATION,
                                     application_role: User.roles[:gord_admin],
                                     project: certification_path.project,
                                     certification_path: certification_path)
      end
      certification_path_count += certification_paths.size
    end while certification_paths.size == PAGE_SIZE

    Rails.logger.info "Found #{ActionController::Base.helpers.pluralize(certification_path_count, 'certification path')} with maximum duration exceeded."
  end

  desc "Create a task for the project/certifier manager for every overdue task"
  task :create_overdue_task, [] => :environment do |t, args|

    Rails.logger.info 'Start creating tasks for overdue tasks...'

    task_count = 0
    page = 0
    begin
      page += 1
      requirements = RequirementDatum.joins(scheme_mix_criteria: [scheme_mix: [:certification_path]])
                         .where(certification_paths: {certification_path_status_id: [CertificationPathStatus::SUBMITTING,
                                                                                    CertificationPathStatus::SUBMITTING_AFTER_SCREENING,
                                                                                    CertificationPathStatus::SUBMITTING_PCR,
                                                                                    CertificationPathStatus::SUBMITTING_AFTER_APPEAL]})
                         .where(status: RequirementDatum.statuses[:required])
                         .where('requirement_data.due_date < ?', Date.current)
                         .page(page).per(PAGE_SIZE)
      requirements.each do |requirement|
        RequirementDatumTask.create(task_description_id: Taskable::PROJ_MNGR_OVERDUE,
                                    project_role: ProjectsUser.roles[:project_manager],
                                    project: requirement.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                                    requirement_datum: requirement)
      end
      task_count += requirements.size
    end while requirements.size == PAGE_SIZE

    page = 0
    begin
      page += 1
      criteria = SchemeMixCriterion.joins(scheme_mix: [:certification_path])
                     .where(certification_paths: {certification_path_status_id: [CertificationPathStatus::VERIFYING,
                                                                                CertificationPathStatus::VERIFYING_AFTER_APPEAL]})
                     .where(status: [SchemeMixCriterion.statuses[:verifying], SchemeMixCriterion.statuses[:verifying_after_appeal]])
                     .where('due_date < ?', Date.current)
                     .page(page).per(PAGE_SIZE)
      criteria.each do |criterion|
        SchemeMixCriterionTask.create(task_description_id: Taskable::CERT_MNGR_OVERDUE,
                                      project_role: ProjectsUser.roles[:certifier_manager],
                                      project: criterion.scheme_mix.certification_path.project,
                                      scheme_mix_criterion: criterion)
      end
      task_count += criteria.size
    end while criteria.size == PAGE_SIZE

    Rails.logger.info "Found #{ActionController::Base.helpers.pluralize(task_count, 'task')} which are overdue."
  end

  desc "Destroy old projects without certificates or with unactivated certificates"
  task :destroy_old_empty_projects, [] => :environment do |t, args|

    Rails.logger.info 'Start destroying old empty projects...'

    projects_count = 0
    page = 0
    begin
      page += 1
      # Destroy projects older than X without activated certificates
      old_empty_projects = Project
                              .where('created_at < ?', DateTime.now - 30.days)
                              .where.not('EXISTS(SELECT id FROM certification_paths WHERE project_id = projects.id AND certification_path_status_id <> ?)', CertificationPathStatus::ACTIVATING)
                              .page(page).per(PAGE_SIZE)
      old_empty_projects.each do |old_empty_project|
        Rails.logger.info 'Destroying ' + old_empty_project.name
        old_empty_project.destroy
      end
      projects_count += old_empty_projects.size
    end while old_empty_projects.size == PAGE_SIZE

    Rails.logger.info "Destroyed #{ActionController::Base.helpers.pluralize(projects_count, 'old empty project')}."
  end

end
