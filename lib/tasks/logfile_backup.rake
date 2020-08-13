namespace :logfile_backup do
  desc "logfile backup"
  task logfile: :environment do
    puts '--- log file in progress ---'
    backup_path = File.join(Rails.root, 'private', 'log', "#{Date.today.year}-#{Date.today.month}")
    unless File.exist?(backup_path)
      FileUtils.mkdir_p(backup_path)
      if Date.today.month - 1 == 0
        FileUtils.rm_r(File.join(Rails.root, 'private', 'log', "#{Date.today.year-1}-#{Date.today.month+11}"), force: true)
      else
        FileUtils.rm_r(File.join(Rails.root, 'private', 'log', "#{Date.today.year}-#{Date.today.month-1}"), force: true)
      end
    end

    filename = File.join(backup_path, "log_#{Time.now.strftime("%a_%Y-%m-%d_%H:%M:%S")}.tar.gz")

    cmd = "tar -czvf #{filename} log/#{Rails.env}.log"
    `#{cmd}`
    Rake::Task["log:clear"].invoke if File.size?(filename)
    puts '--- log file created ---'
  end
end

