class GsasService
  include Singleton

  HOST = 'gord2.sas.vito.local'
  PATH = '/GSASService.svc/CallFunction/'

  STATUS_ERROR = 'error'
  STATUS_SUCCESS = 'success'

  # Sends a function request to the GSAS webservice.
  #
  # The function parameters are:
  # - function_name: The name of the webservice function in CamelCase.
  # - params: A hash with key/value parameters for the webservice function.
  #
  # The function will return a hash with following keys:
  # - status: The status of the response. Can be "success" or "error".
  # - message: An error/success message depending on the status.
  # - score: An integer with the returned calculator score. Only present when status is "success".
  #
  def call_function(function_name, params = {})
    # Build the URI path
    path = PATH + URI.encode(function_name) + '/' + URI.encode(params.to_json)

    # Build the full URI
    begin
      uri = URI::HTTP.build({host: HOST, path: path})
    rescue StandardError
      return {
          status: STATUS_ERROR,
          message: "An error occurred when building a GSAS webservice URI with host: '#{HOST}' and path: '#{path}'. Error message: " + $!.to_s
      }
    end

    # Execute the request
    begin
      response_json = Net::HTTP.get_response(uri)
    rescue StandardError
      return {
          status: STATUS_ERROR,
          message: "An error occurred when executing the GSAS webservice request with uri: '#{uri}'. Error message: " + $!.to_s
      }
    end

    # Parse JSON response body and return
    begin
      JSON.parse response_json.body, :symbolize_names => true
    rescue StandardError
      return {
          status: STATUS_ERROR,
          message: "An error occurred when trying to parse the JSON response of the GSAS webservice request with uri: '#{uri}'. Error message: " + $!.to_s
      }
    end
  end
end