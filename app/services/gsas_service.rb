class GsasService
  include Singleton
  require 'addressable/uri'

  HOST = 'gord2.sas.vito.local'
  PATH = '/GSASService.svc/CallCalculator/'

  STATUS_ERROR = 'error'
  STATUS_SUCCESS = 'success'

  # Sends a function request to the GSAS webservice.
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
  def call_calculator(calculator_name, params = {})
    error = false

    # Build the URI path
    path = PATH + Addressable::URI.encode(calculator_name) + '/' + Addressable::URI.encode(params.to_json)

    # Build the full URI
    begin
      uri = URI::HTTP.build({host: HOST, path: path})
    rescue StandardError
      error = true
      # todo: log this -> "An error occurred when building a GSAS webservice URI with host: '#{HOST}' and path: '#{path}'. Error message: " + $!.to_s
    end

    # Execute the request
    begin
      response_json = Net::HTTP.get_response(uri)
    rescue StandardError
      error = true
      # todo: log this -> "An error occurred when executing the GSAS webservice request with uri: '#{uri}'. Error message: " + $!.to_s
    end

    # Parse JSON response body
    begin
      response_hash = JSON.parse response_json.body, :symbolize_names => true
    rescue StandardError
      error = true
      # todo: log this -> "An error occurred when trying to parse the JSON response of the GSAS webservice request with uri: '#{uri}'. Error message: " + $!.to_s
    end

    # Return hash or error
    if error
      {
          status: STATUS_ERROR,
          message: 'An error occurred when calculating the score. Please try again later.'
      }
    else
      response_hash
    end
  end
end