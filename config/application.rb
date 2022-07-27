require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Gord
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    # Sets the Content-Length header on responses with fixed-length bodies.

    # Autoload classes from STI folders
    config.autoload_paths << Rails.root.join('app', 'models', 'task')

    # Autoload classes from lib
    config.autoload_paths << Rails.root.join('lib')

    # Autoload classes from custom "services" folder (contains GSAS specific services)
    config.autoload_paths << Rails.root.join('services')

    # Autoload classes from custom "strategies" folder (contains Warden strategies)
    # config.autoload_paths << Rails.root.join('strategies')

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
