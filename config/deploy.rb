# Git
set :repo_url, "git@github.com:vishalgord/GSASgate.git"

# Systemd
set :systemd_use_sudo, true
set :systemd_roles, %w(app)
set :systemd_unit, -> { "sas-puma-#{fetch :application}"}

# DB
set :migration_role, :app

# Assets
set :assets_roles, [:app]

# Linked dirs
append :linked_dirs, "log", "private", "tmp/pids", "tmp/cache", "tmp/puma", "tmp/sockets", "public/system", "public/uploads"
append :linked_files, %w{.env}

# Rbenv
#set :rbenv_custom_path, '/usr/local/rbenv'

# Chartgenerator
set :npm_target_path, -> { release_path.join('chartgenerator') }
set :npm_roles, :app
after "deploy:finished", "deploy:start_chartgenerator"

# Ensure scripts can be executed
after "deploy:finished", "deploy:set_script_permissions"

# Custom deploy tasks
namespace :deploy do
  task :start_chartgenerator do
    on roles(:app) do
      within "#{release_path}/chartgenerator" do
        # First argument of "execute" should not contain spaces!
        # See https://capistranorb.com/documentation/getting-started/tasks/
        execute :pm2, :delete, 'pm2-production.json'
        execute :pm2, :start, 'pm2-production.json'
      end
    end
  end

  task :set_script_permissions do
    on roles(:app) do
      within release_path  do
        execute :chmod, '-R 775 sh/'
      end
    end
  end
end

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
