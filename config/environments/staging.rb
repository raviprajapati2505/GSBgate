Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.smtp_settings = { :address => 'smtp.vito.local' }
  config.action_mailer.asset_host = 'http://localhost:3000'

  # Don't log debug & info levels
  config.log_level = :warn

  config.log_tags = [ :uuid ]

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
end