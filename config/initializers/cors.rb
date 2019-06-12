Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:4200', 'gord.vito.be', 'www.gsas.qa'

    resource '/api/*',
             methods: [:get, :post, :options, :delete],
             headers: :any,
             expose: ['Authorization']
  end
  allow do
    origins 'localhost:3000', 'gord.vito.be', 'www.gsas.qa'

    resource '*',
             methods: :any,
             headers: :any
  end
end