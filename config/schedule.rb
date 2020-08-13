# set :environment, ["development", "production", "staging"]
set :output, {:error => 'log/cron.log', :standard => 'log/cron.log'}

every :day, at: '12:00am' do
  rake "gsas:clean_carrierwave_cache"
  rake "gsas:clean_up_expired_archives"
  # rake "gsas:create_duration_task"
  # rake "gsas:create_overdue_task"
  rake "gsas:destroy_old_empty_projects"
  # rake "gsas:send_digest_mail"
end

every 15.minutes do
  rake "gsas:generate_archives"
end

# DumpBasedBackupSet: from Monday to Friday at 11PM (full backup)
every [:monday, :tuesday, :wednesday, :thursday, :friday], at: '11:00pm' do
  rake "db:db_dump_production"
end

# FSBAsedBackupSet: every Friday at 11 PM (full backup)
every :friday, at: '11:00am' do
  # rake 'logfile_backup:logfile'
end

# From Monday to friday at 9AM, 12AM, 3PM and 11PM (log-file backup)
every [:monday, :tuesday, :wednesday, :thursday, :friday], at: ['12:00am', '9:00am', '3:00pm', '11:00pm'] do
  rake 'logfile_backup:logfile'
end

