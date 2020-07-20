namespace :logfile_backup do
  desc "logfile backup"
  task logfile: :environment do
    puts '--- log file in progress ---'
    backup_path = File.join(Rails.root, 'backup', 'log', "#{Date.today.year}-#{Date.today.month}")
    FileUtils.mkdir_p(backup_path) unless File.exist?(backup_path)

    filename = File.join(backup_path, "log_#{Time.now.strftime("%a_%Y-%m-%d_%H:%M:%S")}.tar.gz")

    cmd = "tar -czvf #{filename} log/#{Rails.env}.log"
    `#{cmd}`
    Rake::Task["log:clear"].invoke if File.size?(filename)
    puts '--- log file created ---'
  end
end