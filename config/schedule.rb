# set :environment, ["development", "production", "staging"]
set :output, {:error => 'log/cron.log', :standard => 'log/cron.log'}

every :day, at: '12:00am' do
  rake "gsas:clean_carrierwave_cache"
  rake "gsas:clean_up_expired_archives"
  rake "gsas:create_duration_task"
  rake "gsas:create_overdue_task"
  rake "gsas:destroy_old_empty_projects"
end

# digest mail
every [:sunday, :monday, :tuesday, :wednesday, :thursday], at: '5:00pm' do
  rake "gsas:send_digest_mail"
end

every 15.minutes do
  rake "gsas:generate_archives"
end

# DumpBasedBackupSet: every day at 10:30PM (full backup)
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

every :day, at: '10:00am' do
  rake "gsas:send_expiry_mail"
end

every :day, at: ['12:30am', '9:30am', '3:30pm', '11:30pm'] do
  rake "backup_clean:log_backup_clean"
end