namespace :gsb do

  PAGE_SIZE = 100

  # usage example: rake gsb:send_digest_mail[<username>]
  desc 'Send email to users with a digest of their most recent project changes and their list of unfinished tasks'
  task :send_digest_mail, [:username] => :environment do |t, args|

    puts 'Start sending emails...'

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
        users = User.active.page(page).per(PAGE_SIZE)
        users.each do |user|
          DigestMailer.digest_email(user).deliver_now
        end
        user_count += users.size
      end while users.size == PAGE_SIZE
    end

    puts "Processed #{ActionController::Base.helpers.pluralize(user_count, 'user')}."
  end

  desc 'Create a task for the system admin for every expired certification path'
  task :create_duration_task, [] => :environment do |t, args|

    puts 'Start creating tasks for expired certification paths...'

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
                                .where(certificates: {certificate_type: Certificate.certificate_types[:design_type]})
                                .where.not(certification_path_status_id: [CertificationPathStatus::CERTIFIED, CertificationPathStatus::NOT_CERTIFIED])
                                .where('expires_at < ?', DateTime.now)
      unless from_datetime.nil?
        certification_paths = certification_paths.where('expires_at >= ?', from_datetime)
      end
      certification_paths = certification_paths.page(page).per(PAGE_SIZE)
      certification_paths.each do |certification_path|
        Task.find_or_create_by(taskable: certification_path,
                    task_description_id: Taskable::SYS_ADMIN_DURATION,
                    application_role: User.roles[:gsb_trust_admin],
                    project: certification_path.project,
                    certification_path: certification_path)
        DigestMailer.certification_expired_email(certification_path).deliver_now
      end
      certification_path_count += certification_paths.size
    end while certification_paths.size == PAGE_SIZE

    puts "Found #{ActionController::Base.helpers.pluralize(certification_path_count, 'certification path')} which are expired."
  end

  desc 'Send email notifications for the CGP manager for all certification paths that expire within 3/2/1 month'
  task :send_expiry_mail, [] => :environment do |t, args|

    puts 'Start sending expiry emails...'

    backgroundExecution = BackgroundExecution.find_by(name: BackgroundExecution::EXPIRY_TASK)
    if backgroundExecution.nil?
      from_datetime = nil
      backgroundExecution = BackgroundExecution.new(name: BackgroundExecution::EXPIRY_TASK)
      backgroundExecution.save
    else
      from_datetime = backgroundExecution.updated_at
      backgroundExecution.touch
    end

    certification_path_count = 0
    page = 0
    begin
      page += 1
      certification_paths = CertificationPath.joins(:certificate)
                                .where(certificates: {certificate_type: Certificate.certificate_types[:design_type]})
                                .where.not(certification_path_status_id: [CertificationPathStatus::CERTIFIED, CertificationPathStatus::NOT_CERTIFIED])
                                .where('expires_at < ?', 3.months.from_now)
      unless from_datetime.nil?
        certification_paths = certification_paths.where('((expires_at - interval \'3 months\') >= ? and (expires_at - interval \'3 months\') < current_timestamp) or ((expires_at - interval \'2 months\') >= ? and (expires_at - interval \'2 months\') < current_timestamp) or ((expires_at - interval \'1 months\') >= ? and (expires_at - interval \'1 months\') < current_timestamp)', from_datetime, from_datetime, from_datetime)
      end
      certification_paths = certification_paths.page(page).per(PAGE_SIZE)
      certification_paths.each do |certification_path|
        DigestMailer.certification_expires_in_near_future_email(certification_path).deliver_now
      end

      certification_path_count += certification_paths.size
    end while certification_paths.size == PAGE_SIZE

    puts "Found #{ActionController::Base.helpers.pluralize(certification_path_count, 'certification path')} which expires within 3 months."
  end

  desc 'Create a task for the CGP project manager or certification manager for every overdue task'
  task :create_overdue_task, [] => :environment do |t, args|

    puts 'Start creating tasks for overdue tasks...'

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
        Task.find_or_create_by(taskable: requirement,
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
        Task.find_or_create_by(taskable: criterion,
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
        Task.find_or_create_by(taskable: criterion,
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
        Task.find_or_create_by(taskable: criterion,
                    task_description_id: Taskable::CERT_MNGR_OVERDUE,
                    project_role: ProjectsUser.roles[:certification_manager],
                    project: criterion.scheme_mix.certification_path.project,
                    certification_path: criterion.scheme_mix.certification_path)
      end
      task_count += criteria.size
    end while criteria.size == PAGE_SIZE

    puts "Found #{ActionController::Base.helpers.pluralize(task_count, 'task')} which are overdue."
  end

  desc 'Destroy old projects without certificates or with unactivated certificates'
  task :destroy_old_empty_projects, [] => :environment do |t, args|

    puts 'Start destroying old empty projects...'

    projects_count = 0
    page = 0
    begin
      page += 1
      # Destroy projects older than X without activated certificates
      old_empty_projects = Project
                              .where('created_at < ?', DateTime.now - 60.days)
                              .where.not('EXISTS(SELECT id FROM certification_paths WHERE project_id = projects.id AND certification_path_status_id <> ?)', CertificationPathStatus::ACTIVATING)
                              .page(page).per(PAGE_SIZE)
      old_empty_projects.each do |old_empty_project|
        puts 'Destroying ' + old_empty_project.name
        old_empty_project.destroy
      end
      projects_count += old_empty_projects.size
    end while old_empty_projects.size == PAGE_SIZE

    puts "Destroyed #{ActionController::Base.helpers.pluralize(projects_count, 'old empty project')}."
  end

  desc 'Clean Carrierwave cache dir'
  task :clean_carrierwave_cache, [] => :environment do |t, args|
    puts 'Start cleaning Carrierwave cache dir'
    CarrierWave.clean_cached_files!
    puts 'Carrierwave cache dir cleaned'
  end

  desc 'Clean up expired archives'
  task :clean_up_expired_archives, [] => :environment do |t, args|
    puts 'Cleaning up expired archives'

    expired_archives = Archive.where('updated_at < ? AND status = ?', Time.now - 1.day, Archive.statuses[:generated])

    expired_archives.each do |archive|
      puts "- Cleaning up archive #{archive.id}"

      begin
        File.delete(archive.archive_path) if archive.archive_file.present?
      rescue Errno::ENOENT => e
        puts "-- File for archive #{archive.id} was not found on disk"
      end

      archive.delete
    end

    puts 'Expired archives were cleaned'
  end

  desc 'Generate archives'
  task :generate_archives, [] => :environment do |t, args|
    puts 'Generate archives'

    ungenerated_archives = Archive.not_generated

    ungenerated_archives.each do |archive|
      puts "- Generating archive #{archive.id}"
      archive.generate!
      DigestMailer.archive_created_email(archive).deliver_now
    end

    puts 'All archives generated'
  end

end
