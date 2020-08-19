namespace :backup_clean do

  LAST_DATE = Time.now - 30.days

  desc "Delete db backup files which are generated before 30 days."
  task db_backup_clean: :environment do
    puts "--- start deleting db backup files ---"
    base_path = File.join(Rails.root, 'private', 'database_backup')

    file = File.join(base_path, "db_backup_#{LAST_DATE.strftime("%Y-%m-%d")}")
    FileUtils.rm_r((file), force: true) if File.exist?(file)
    puts "--- deleted db bachup files ---"
  end

  desc "Delete log backup files which are generated before 30 days."
  task log_backup_clean: :environment do
    puts "--- start deleting log backup files ---"
    base_path = File.join(Rails.root, 'private', 'log_backup')

    file = File.join(base_path, "log_backup_#{LAST_DATE.strftime("%Y-%m-%d_%H")}.tar.gz")  
    FileUtils.rm_r((file), force: true) if File.exist?(file)
    puts "--- deleted log bachup files ---"
  end

end