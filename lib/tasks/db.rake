namespace :db do

  namespace :seed do
    task :single => :environment do
      filename = Dir[File.join(Rails.root, 'db', 'seeds', "#{ENV['SEED']}.rb")][0]
      puts "Seeding #{filename}..."
      load(filename) if File.exist?(filename)
    end
  end

  def dump_path
    base_path = File.join(Rails.root, 'private', 'database_backup')
    backup_path = File.join(base_path, "#{Date.today.year}-#{Date.today.month}")
    
    FileUtils.mkdir_p(backup_path) unless File.exist?(backup_path)
      
    backup_path
  end

  def db_name(env)
    config = Rails.configuration.database_configuration[env]
    "#{config['adapter']}://#{config['username']}:#{config['password']}@/#{config['host']}#{config['database']}"
  end

  desc 'Dump database to local file'
  task :db_dump_production do
    puts '--- dump in progress ---'
    filename = File.join(dump_path, "db_backup_#{Time.now.strftime("%a_%Y-%m-%d")}")
    config = Rails.configuration.database_configuration[Rails.env]
    if config.has_key?('url')
      cmd = "pg_dump --format=c #{config['url']} --file=#{filename}"
    else
      cmd = "PGPASSWORD=#{config['password']} pg_dump --format=c --host=#{config['host']} --username=#{config['username']} --dbname=#{config['database']} --file=#{filename}"      
    end
    system cmd or raise "Error dumping database"
    puts '--- dump created ---'
  end

  desc 'Load production database dump into development database'
  task :db_load_into_development do
    config = Rails.configuration.database_configuration['development']
    cmd = "pg_restore -v --clean --no-owner --host=#{config['host']} --username=#{config['username']} --dbname=#{config['database']} #{dump_path}"
    system cmd or raise "Error restoring database"
  end
end
