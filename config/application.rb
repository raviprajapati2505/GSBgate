require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Gord
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Autoload classes from STI folders
    config.autoload_paths << Rails.root.join('app', 'models', 'task')

    # Autoload classes from custom "services" folder (contains GSAS specific services)
    config.autoload_paths << Rails.root.join('services')

    # Autoload classes from custom "strategies" folder (contains Warden strategies)
    # config.autoload_paths << Rails.root.join('strategies')

    # Sets the Content-Length header on responses with fixed-length bodies.
    config.middleware.use Rack::ContentLength

    # Autoload classes from "lib" folder (https://gist.github.com/maxim/6503591)
    config.watchable_dirs['lib'] = [:rb]

    # Create own routes for error pages
    config.exceptions_app = self.routes

    # Custom GORD config
    config.x.tools_controller.url = 'http://127.0.0.1:4034'

    config.time_zone = 'Asia/Qatar'

  end
end
