
class GsbService
  require 'addressable/uri'
  include Singleton
  include HTTParty
  uri_adapter Addressable::URI

  SCHEME = 'http'
  HOST = 'gord2.sas.vito.local'
  PATH = 'GSBService.svc/CallCalculator'

  STATUS_ERROR = 'error'
  STATUS_SUCCESS = 'success'

  # Sends a function request to the GSB webservice.
  #
  # The function parameters are:
  # - calculator_name: The name of the calculator in CamelCase.
  # - params: A hash with key/value parameters for the webservice function.
  #
  # The function will return a hash with following keys:
  # - status: The status of the response. Can be "success" or "error".
  # - message: An error/success message depending on the status.
  # - score: An integer with the returned calculator score. Only present when status is "success".
  #
  def call_calculator(calculator_name, data = {})
    begin
      # Build the URI
      uri_string = "#{SCHEME}://#{HOST}/#{PATH}/#{calculator_name}"
      uri = Addressable::URI.escape(uri_string)
      # Do the request
      response = self.class.post(uri, {body: data.to_json, headers: {'Content-Type' => 'application/javascript'}})
      # Parse body, should contain json
      response_hash = JSON.parse response.body, :symbolize_names => true
    rescue StandardError
      Rails.logger.error "An error occurred when building a GSB webservice URI with host: '#{HOST}' and path: '#{path}'. Error message: " + $!.to_s
      response_hash = {
            status: STATUS_ERROR,
            message: 'An error occurred when calculating the score. Please try again later.'
      }
    end
    response_hash
  end

end
