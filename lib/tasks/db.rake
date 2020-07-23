namespace :db do

  namespace :seed do
    task :single => :environment do
      filename = Dir[File.join(Rails.root, 'db', 'seeds', "#{ENV['SEED']}.rb")][0]
      puts "Seeding #{filename}..."
      load(filename) if File.exist?(filename)
    end
  end

  def dump_path
    Rails.root.join('private/production_backup').to_path
  end

  def db_name(env)
    config = Rails.configuration.database_configuration[env]
    "#{config['adapter']}://#{config['username']}:#{config['password']}@/#{config['host']}#{config['database']}"
  end

  desc 'Dump database to local file'
  task :db_dump_production do
    puts '--- dump in progress ---'
    config = Rails.configuration.database_configuration['production'] if Rails.env.production?
    config = Rails.configuration.database_configuration['staging'] if Rails.env.staging?
    config = Rails.configuration.database_configuration['development'] if  Rails.env.development? 
    if config.has_key?('url')
      cmd = "pg_dump --format=c #{config['url']} --file=#{dump_path}"
    else
      cmd = "pg_dump --format=c --host=#{config['host']} --username=#{config['username']} --dbname=#{config['database']} --file=#{dump_path}"
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
