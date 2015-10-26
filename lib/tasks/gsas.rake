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
        users = User.all.paginate page: page, per_page: PAGE_SIZE
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

    Rails.logger.info 'Start creating duration tasks...'

    certification_path_count = 0
    page = 0
    begin
      page += 1
      certification_paths = CertificationPath.where('(started_at + interval \'1\' year * duration) < ?', DateTime.now).paginate page: page, per_page: PAGE_SIZE
      certification_paths.each do |certification_path|
        CertificationPathTask.create(task_description_id: Taskable::SYS_ADMIN_DURATION,
                                     application_role: User.roles[:system_admin],
                                     project: certification_path.project,
                                     certification_path: certification_path)
      end
      certification_path_count += certification_paths.size
    end while certification_paths.size == PAGE_SIZE

    Rails.logger.info "Found #{ActionController::Base.helpers.pluralize(certification_path_count, 'certification path')} with maximum duration exceeded."
  end

end
