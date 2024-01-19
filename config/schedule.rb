# set :environment, ["development", "production", "staging"]
set :output, {:error => 'log/cron.log', :standard => 'log/cron.log'}

every :day, at: '12:00am' do
  rake "gsb:clean_carrierwave_cache"
  rake "gsb:clean_up_expired_archives"
  rake "gsb:destroy_old_empty_projects"
end

every 15.minutes do
  rake "gsb:generate_archives"
end

# DumpBasedBackupSet: every day at 11PM (full backup)
every :day, at: '10:30pm' do
  rake "db:db_dump_production"
end

# every day at 9AM, 12AM, 3PM and 11PM (log-file backup)
every :day, at: ['12:00am', '9:00am', '3:00pm', '11:00pm'] do
  rake 'logfile_backup:logfile'
end

every :day, at: '10:00pm' do
  rake "backup_clean:db_backup_clean"
end

every :day, at: ['12:30am', '9:30am', '3:30pm', '11:30pm'] do
  rake "backup_clean:log_backup_clean"
end

# puts "#{@environment}" this code for production enviroment
case @environment
  when 'production'
    # digest mail
    every :day, at: '5:00pm' do
      rake "gsb:send_digest_mail"
    end

    every :day, at: '10:00am' do
      rake "gsb:send_expiry_mail"
    end

    every :day, at: '12:00am' do
      rake "gsb:create_duration_task" #--> production
      rake "gsb:create_overdue_task"  #--> production
    end
end