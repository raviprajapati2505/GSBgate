Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false


  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Mailer settings
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.smtp_settings = { :address => 'smtp.vito.local' }
  config.action_mailer.asset_host = 'http://localhost:3000'

  # Prepend all log lines with the following tags.
  config.log_tags = [ :uuid ]

  # GSAS info email addresses
  config.x.gsas_info.email = 'sas@vito.be'

  # Linkme.qa API config
  config.x.linkme.api_url = 'api.yourmembership.com'
  config.x.linkme.api_verion = '2.03'
  config.x.linkme.public_api_key = '05BE43AB-B4FF-4E0B-89F3-9A1F3C281152'
  config.x.linkme.private_api_key = '5D621211-8E39-4871-A3F3-05C5C8833A57'
  config.x.linkme.sa_passcode = 'Y05KzqB77cs6'

  # Chart generator API config
  config.x.chart_generator.api_url = 'localhost'
  config.x.chart_generator.api_port = 8082

  # Visualisation Tool API
  config.x.viewer.url = 'http://localhost:4200'
end
