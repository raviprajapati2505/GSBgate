# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:4200', 'stagingvisualisation.gsb.qa', 'visualisation.gsb.qa'

    resource '/api/*',
             methods: [:get, :post, :options, :delete],
             headers: :any,
             expose: ['Authorization']
  end
  allow do
    origins 'localhost:4200', 'stagingvisualisation.gsb.qa', 'visualisation.gsb.qa'

    resource '/users/*',
             methods: [:get, :post, :options, :delete],
             headers: :any,
             expose: ['Authorization']
  end
  allow do
    origins 'localhost:3000', 'staging.gsb.qa', 'www.gsb.qa'

    resource '*',
             methods: :any,
             headers: :any
  end
end