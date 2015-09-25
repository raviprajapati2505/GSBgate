namespace :gsas do

  PAGE_SIZE = 100

  # usage example: rake gsas:send_digest_mail dry_run=false
  desc "Send email to users with a digest of their most recent project changes and their list of unfinished tasks"
  task :send_digest_mail, [:dry_run] => :environment do |t, args|
    args.with_defaults(dry_run: false)

    Rails.logger.info 'Start sending emails...'

    user_count = 0
    page = 0
    begin
      page += 1
      users = User.all.paginate page: page, per_page: PAGE_SIZE
      users.each do |user|
        unless args.dry_run
          DigestMailer.digest_email(user).deliver_now
        end
      end
      user_count += users.size
    end while users.size == PAGE_SIZE

    Rails.logger.info "Processed #{user_count} users."
  end

end
