# A service that generates graphs using on chart.js
class ChartGeneratorService
  def generate_chart(config, width, height)
    # Build the URL
    url = URI::HTTP.build(host: Rails.application.config.x.chart_generator.api_url, path: "/#{width}x#{height}.png", port: Rails.application.config.x.chart_generator.api_port)

    # Prepare a POST request
    request = Net::HTTP::Post.new(url.to_s, {'Host' => url.hostname, 'Content-Type' => 'application/json'})

    # Add the XML request body
    request.body = config.to_json

    # Execute the request
    response = Net::HTTP.start(url.hostname, Rails.application.config.x.chart_generator.api_port, use_ssl: false) do |http|
      http.request request
    end

    if (response.body.blank? || response.code.blank? || response.message.blank?)
      raise ApiError, 'Invalid response'
    elsif (response.code != '200')
      raise ApiError, 'HTTP error ' + response.code + ' ' + response.message
    else
      tempfile = Tempfile.new('gsas-chart.png')
      File.open(tempfile.path, 'w:ASCII-8BIT') do |f|
        f.write response.body
      end
      return tempfile
    end
  end

  # General error class
  class ApiError < StandardError
  end
end