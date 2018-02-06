namespace :gsas do

  PAGE_SIZE = 100

  # usage example: rake gsas:send_digest_mail[<username>]
  desc 'Send email to users with a digest of their most recent project changes and their list of unfinished tasks'
  task :send_digest_mail, [:username] => :environment do |t, args|

    Rails.logger.info 'Start sending emails...'

    user_count = 0
    if args.username.present?
      user = User.find_by_username(args.username)
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

  desc 'Create a task for the system admin for every expired certification path'
  task :create_duration_task, [] => :environment do |t, args|

    Rails.logger.info 'Start creating tasks for expired certification paths...'

    backgroundExecution = BackgroundExecution.find_by(name: BackgroundExecution::DURATION_TASK)
    if backgroundExecution.nil?
      from_datetime = nil
      backgroundTask = BackgroundExecution.new(name: BackgroundExecution::DURATION_TASK)
      backgroundTask.save
    else
      from_datetime = backgroundExecution.updated_at
      backgroundExecution.touch
    end

    certification_path_count = 0
    page = 0
    begin
      page += 1
      certification_paths = CertificationPath.joins(:certificate)
                                .where(certificates: {certificate_type: Certificate.certification_types[:design_type]})
                                .where.not(certification_path_status_id: [CertificationPathStatus::CERTIFIED, CertificationPathStatus::NOT_CERTIFIED])
                                .where('expires_at < ?', DateTime.now)
      unless from_datetime.nil?
        certification_paths = certification_paths.where('expires_at >= ?', from_datetime)
      end
      certification_paths = certification_paths.page(page).per(PAGE_SIZE)
      certification_paths.each do |certification_path|
        Task.create(taskable: certification_path,
                    task_description_id: Taskable::SYS_ADMIN_DURATION,
                    application_role: User.roles[:gsas_trust_admin],
                    project: certification_path.project,
                    certification_path: certification_path)
        DigestMailer.certification_expired_email(certification_path).deliver_now
      end
      certification_path_count += certification_paths.size
    end while certification_paths.size == PAGE_SIZE

    Rails.logger.info "Found #{ActionController::Base.helpers.pluralize(certification_path_count, 'certification path')} which are expired."
  end

  desc 'Create a task for the CGP project manager or certification manager for every overdue task'
  task :create_overdue_task, [] => :environment do |t, args|

    Rails.logger.info 'Start creating tasks for overdue tasks...'

    backgroundExecution = BackgroundExecution.find_by(name: BackgroundExecution::OVERDUE_TASK)
    if backgroundExecution.nil?
      from_datetime = nil
      backgroundTask = BackgroundExecution.new(name: BackgroundExecution::OVERDUE_TASK)
      backgroundTask.save
    else
      from_datetime = backgroundExecution.updated_at
      backgroundExecution.touch
    end

    task_count = 0
    page = 0
    begin
      page += 1
      requirements = RequirementDatum.joins(scheme_mix_criteria: [scheme_mix: [:certification_path]])
                         .where(certification_paths: {certification_path_status_id: [CertificationPathStatus::SUBMITTING,
                                                                                    CertificationPathStatus::SUBMITTING_AFTER_SCREENING,
                                                                                    CertificationPathStatus::SUBMITTING_AFTER_APPEAL]})
                         .where(status: RequirementDatum.statuses[:required])
                         .where('requirement_data.due_date < ?', Date.current)
      unless from_datetime.nil?
        requirements = requirements.where('requirement_data.due_date >= ?', from_datetime)
      end
      requirements = requirements.page(page).per(PAGE_SIZE)
      requirements.each do |requirement|
        Task.create(taskable: requirement,
                    task_description_id: Taskable::PROJ_MNGR_OVERDUE,
                    project_role: ProjectsUser.roles[:cgp_project_manager],
                    project: requirement.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                    certification_path: requirement.scheme_mix_criteria.first.scheme_mix.certification_path)
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
      unless from_datetime.nil?
        criteria = criteria.where('due_date >= ?', from_datetime)
      end
      criteria = criteria.page(page).per(PAGE_SIZE)
      criteria.each do |criterion|
        Task.create(taskable: criterion,
                    task_description_id: Taskable::CERT_MNGR_OVERDUE,
                    project_role: ProjectsUser.roles[:certification_manager],
                    project: criterion.scheme_mix.certification_path.project,
                    certification_path: criterion.scheme_mix.certification_path)
      end
      task_count += criteria.size
    end while criteria.size == PAGE_SIZE

    page = 0
    begin
      page += 1
      criteria = SchemeMixCriterion.joins(scheme_mix: [:certification_path])
                     .where(certification_paths: {certification_path_status_id: CertificationPathStatus::SCREENING})
                     .where(screened: false)
                     .where('due_date < ?', Date.current)
      unless from_datetime.nil?
        criteria = criteria.where('due_date >= ?', from_datetime)
      end
      criteria = criteria.page(page).per(PAGE_SIZE)
      criteria.each do |criterion|
        Task.create(taskable: criterion,
                    task_description_id: Taskable::CERT_MNGR_OVERDUE,
                    project_role: ProjectsUser.roles[:certification_manager],
                    project: criterion.scheme_mix.certification_path.project,
                    certification_path: criterion.scheme_mix.certification_path)
      end
      task_count += criteria.size
    end while criteria.size == PAGE_SIZE

    page = 0
    begin
      page += 1
      criteria = SchemeMixCriterion.joins(scheme_mix: [:certification_path])
                     .where(certification_paths: {certification_path_status_id: [CertificationPathStatus::SUBMITTING,
                                                                                 CertificationPathStatus::SUBMITTING_AFTER_SCREENING]})
                     .where(in_review: true)
                     .where(pcr_review_draft: nil)
                     .where('due_date < ?', Date.current)
      unless from_datetime.nil?
        criteria = criteria.where('due_date >= ?', from_datetime)
      end
      criteria = criteria.page(page).per(PAGE_SIZE)
      criteria.each do |criterion|
        Task.create(taskable: criterion,
                    task_description_id: Taskable::CERT_MNGR_OVERDUE,
                    project_role: ProjectsUser.roles[:certification_manager],
                    project: criterion.scheme_mix.certification_path.project,
                    certification_path: criterion.scheme_mix.certification_path)
      end
      task_count += criteria.size
    end while criteria.size == PAGE_SIZE

    Rails.logger.info "Found #{ActionController::Base.helpers.pluralize(task_count, 'task')} which are overdue."
  end

  desc 'Destroy old projects without certificates or with unactivated certificates'
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

  desc 'Clean Carrierwave cache dir'
  task :clean_carrierwave_cache, [] => :environment do |t, args|
    Rails.logger.info 'Start cleaning Carrierwave cache dir'
    CarrierWave.clean_cached_files!
    Rails.logger.info 'Carrierwave cache dir cleaned'
  end

  desc 'Clean up expired archives'
  task :clean_up_expired_archives, [] => :environment do |t, args|
    Rails.logger.info 'Cleaning up expired archives'

    expired_archives = Archive.where('created_at < ? AND status = ?', Time.now - 1.day, Archive.statuses[:generated])

    puts expired_archives.inspect

    expired_archives.each do |archive|
      puts "- Cleaning up archive #{archive.id}"
      File.delete(archive.archive_path) if archive.archive_file.present?
      archive.delete
    end

    Rails.logger.info 'Expired archives were cleaned'
  end

end
