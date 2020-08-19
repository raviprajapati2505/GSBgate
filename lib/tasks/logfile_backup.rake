namespace :logfile_backup do
  desc "logfile backup"
  task logfile: :environment do
    puts '--- log file in progress ---'
    base_path = File.join(Rails.root, 'private', 'log_backup')

    FileUtils.mkdir_p(base_path) unless File.exist?(base_path)

    filename = File.join(base_path, "log_backup_#{Time.now.strftime("%Y-%m-%d_%H")}.tar.gz")

    cmd = "tar -czvf #{filename} log/#{Rails.env}.log"
    `#{cmd}`
    Rake::Task["log:clear"].invoke if File.size?(filename)
    puts '--- log file created ---'
  end
end