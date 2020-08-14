Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:4200', 'stagingvisualisation.gsas.qa', 'visualisation.gsas.qa'

    resource '/api/*',
             methods: [:get, :post, :options, :delete],
             headers: :any,
             expose: ['Authorization']
  end
  allow do
    origins 'localhost:4200', 'stagingvisualisation.gsas.qa', 'visualisation.gsas.qa'

    resource '/users/*',
             methods: [:get, :post, :options, :delete],
             headers: :any,
             expose: ['Authorization']
  end
  allow do
    origins 'localhost:3000', 'stagingvisualisation.gsas.qa', 'www.gsas.qa', 'https://gctprojects.qa', "http://gctprojects.qa"


    resource '*',
             methods: :any,
             headers: :any
  end
end