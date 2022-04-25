Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = Uglifier.new(harmony: true)
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug
  config.logger = ActiveSupport::Logger.new("log/#{Rails.env}.log")

  # Prepend all log lines with the following tags.
  config.log_tags = [ :uuid ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "gord_#{Rails.env}"

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Mailer settings
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { :host => 'https://staging.gsas.qa' }
  config.action_mailer.asset_host = 'https://staging.gsas.qa'

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { 
    :user_name => ENV['SENDGRID_USERNAME'],
    :password => ENV['SENDGRID_PASSWORD'],
    :domain => 'gsas.qa',
    :address => 'smtp.sendgrid.net',
    :port =>  '587',
    :authentication => :plain,
    :enable_starttls_auto => true
  }

  # GSAS info email addresses for test env only
  config.x.gsas_info.all_notifications_email = 'no-reply@gord.qa'

  # Linkme.qa newer API config
  config.x.linkme.api_url = 'https://ws.yourmembership.com'
  config.x.linkme.api_verion = '2.03'
  config.x.linkme.api_key = '576e28a8-4dd7-406d-ad50-e58c272bd84d'
  config.x.linkme.api_password = '092f197c-87c7-42a3-9537-ae7fb4520362'
  config.x.linkme.client_id = 34560

  # Chart generator API config
  config.x.chart_generator.api_url = 'localhost'
  config.x.chart_generator.api_port = 8082

  # Visualisation Tool API
  config.x.viewer.url = ENV['VIEWER_URL']
  config.devise_jwt_secret_key = 'a311b69f11b4b84b5b5b214f2965dfa46f8e54374c08042ab58dbdaa93aed8eff4d775625ffeb2ed8bf0093f0628a0618feded6cb8898092bc9f6698bd60bfc6'

end
