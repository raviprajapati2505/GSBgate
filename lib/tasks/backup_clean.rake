namespace :backup_clean do

  PREVIOUS_DATE = Time.now - 60.days
  LAST_DATE = Time.now - 30.days

  desc "Delete db backup files which are generated before 30 days."
  task db_backup_clean: :environment do
    puts "--- start deleting db backup files ---"
    base_path = File.join(Rails.root, 'private', 'database_backup')

    last_month_directory = File.join(base_path, "#{PREVIOUS_DATE.year}-#{PREVIOUS_DATE.month}")
    FileUtils.rm_r((last_month_directory), force: true) if File.exist?(last_month_directory)

    file = File.join(base_path, "#{LAST_DATE.year}-#{LAST_DATE.month}", "db_backup_#{LAST_DATE.strftime("%a_%Y-%m-%d")}")
    FileUtils.rm_r((file), force: true) if File.exist?(file)
    puts "--- deleted db bachup files ---"
  end

  desc "Delete log backup files which are generated before 30 days."
  task log_backup_clean: :environment do
    puts "--- start deleting log backup files ---"
    base_path = File.join(Rails.root, 'private', 'log')

    last_month_directory = File.join(base_path, "#{PREVIOUS_DATE.year}-#{PREVIOUS_DATE.month}")
    FileUtils.rm_r((last_month_directory), force: true) if File.exist?(last_month_directory)

    file = File.join(base_path, "#{LAST_DATE.year}-#{LAST_DATE.month}", "log_#{LAST_DATE.strftime("%a_%Y-%m-%d_%H")}.tar.gz")  
    FileUtils.rm_r((file), force: true) if File.exist?(file)
    puts "--- deleted log bachup files ---"
  end

end