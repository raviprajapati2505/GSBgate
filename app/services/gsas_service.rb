class GsasService
  include Singleton

  GSAS_SERVICE_HOST = 'gord2.sas.vito.local'
  GSAS_SERVICE_PATH = '/GSASService.svc/CallFunction/'

  GSAS_SERVICE_STATUS_ERROR = 'error'
  GSAS_SERVICE_STATUS_SUCCESS = 'success'

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
    path = GSAS_SERVICE_PATH + URI.encode(function_name) + '/' + URI.encode(params.to_json)

    # Build the full URI
    begin
      uri = URI::HTTP.build({host: GSAS_SERVICE_HOST, path: path})
    rescue StandardError
      return {
          status: GSAS_SERVICE_STATUS_ERROR,
          message: "An error occurred when building a GSAS webservice URI with host: '#{GSAS_SERVICE_HOST}' and path: '#{path}'. Error message: " + $!.to_s
      }
    end

    # Execute the request
    begin
      response = Net::HTTP.get_response(uri)
    rescue StandardError
      return {
          status: GSAS_SERVICE_STATUS_ERROR,
          message: "An error occurred when executing the GSAS webservice request with uri: '#{uri}'. Error message: " + $!.to_s
      }
    end

    # Parse JSON response body and return
    begin
      JSON.parse response.body
    rescue StandardError
      return {
          status: GSAS_SERVICE_STATUS_ERROR,
          message: "An error occurred when trying to parse the JSON response of the GSAS webservice request with uri: '#{uri}'. Error message: " + $!.to_s
      }
    end
  end
end