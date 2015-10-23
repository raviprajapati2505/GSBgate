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

end
