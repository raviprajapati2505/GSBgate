# An interface for the linkme.qa API, built on yourmembership.com.
# For more info on the API, see http://www.yourmembership.com/company/api-reference/
class LinkmeService
  require 'nokogiri'

  attr_accessor :call_id
  attr_accessor :session_id

  # Session.Create
  def session_create
    request_xml = prepare_api_request('Session.Create')
    response_xml = execute_api_request(request_xml)
    @session_id = response_xml.at_xpath('//Session.Create//SessionID').text
  end

  # Session.Abandon
  def session_abandon
    request_xml = prepare_api_request('Session.Abandon', session_id: @session_id)
    execute_api_request(request_xml)
  end

  # Auth.Authenticate
  # Authenticates a linkme.qa user. On success, the user will be linked to the current API session.
  # Returns TRUE if successful, FALSE if unsuccessful.
  def auth_authenticate(username, password)
    request_xml = prepare_api_request('Auth.Authenticate', method_params: {Username: username, Password: password}, session_id: @session_id)
    response_xml = execute_api_request(request_xml)
    response_xml.at_xpath('//Auth.Authenticate//ID').present?
  end

  # Member.Profile.Get
  # Retrieves the member profile of the linkme.qa user that is linked to the current API session.
  # Returns a hash containing the member info.
  def member_profile_get
    request_xml = prepare_api_request('Member.Profile.Get', session_id: @session_id)
    response_xml = execute_api_request(request_xml)
    {
        id: response_xml.at_xpath('//Member.Profile.Get//ID').text,
        username: response_xml.at_xpath('//Member.Profile.Get//Username').text,
        email: response_xml.at_xpath('//Member.Profile.Get//EmailAddr').text,
        membership: response_xml.at_xpath('//Member.Profile.Get//Membership').text,
        employer: response_xml.at_xpath('//Member.Profile.Get//Employer').text
    }
  end

  # Sa.People.Profile.FindID
  def sa_people_profile_findid
    # todo
  raise NotImplementedError
  end

  # Sa.People.Profile.Get
  def sa_people_profile_get
    # todo
    raise NotImplementedError
  end

  private
  # Prepares the XML body that can be used to send an API request
  # - method: A string containing the API method that will be called.
  # - extra_params: A hash with (optional) extra parameters.
  #   - extra_params.method_params: A hash with parameters that will be added to the method call.
  #   - extra_params.session_id: Provide a session id for API requests that require a session.
  #   - extra_params.sa_request: Set to TRUE to add the SaPasscode to the request parameters.
  def prepare_api_request(method, extra_params = {})
    # Increment the call id
    @call_id ||= 0
    @call_id = @call_id + 1

    # Prepare request body XML
    Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
      xml.YourMembership {
        xml.Version Rails.application.config.x.linkme.api_verion
        xml.ApiKey Rails.application.config.x.linkme.private_api_key
        xml.CallID @call_id.to_s
        if extra_params[:method_params].present?
          xml.Call(Method: method) {
            extra_params[:method_params].each_with_index do |(name, value), index|
              xml.send(name, value)
            end
          }
        else
          xml.Call(Method: method)
        end
        if extra_params[:session_id].present?
          xml.SessionID extra_params[:session_id]
        elsif (extra_params[:sa_request].present? && extra_params[:sa_request])
          xml.SaPasscode Rails.application.config.x.linkme.sa_passcode
        end
      }
    end
  end

  # Executes an API request.
  # - request_xml: The XML body that will be sent with the request.
  def execute_api_request(request_xml)
    begin
      # Build the API URL
      url = URI::HTTPS.build(host: Rails.application.config.x.linkme.api_url)

      # Prepare a POST request
      request = Net::HTTP::Post.new(url.to_s, {'Host' => url.hostname, 'Content-Type' => 'application/x-www-form-urlencoded'})

      # Add the XML request body
      request.body = request_xml.to_xml

      # Execute the request
      response = Net::HTTP.start(url.hostname, use_ssl: true) do |http|
        http.request request
      end

      if (response.body.blank? || response.code.blank? || response.message.blank?)
        raise ApiError, 'Invalid response'
      elsif (response.code != '200')
        raise ApiError, 'HTTP error ' + response.code + ' ' + response.message
      else
        # Parse the response XML
        response_xml = Nokogiri::XML(response.body)

        # Get the error code
        error_code = response_xml.at_xpath('//ErrCode').text

        # Return response or handle error
        if error_code == '0'
          # When there's no error, return the response XML
          response_xml
        else
          error_description = 'API error ' + error_code + ' ' + response_xml.at_xpath('//ErrDesc').text
          case error_code
            when '406'
              # Method could not uniquely identify a record on which to operate.
              raise NotFoundError, error_description
            when '501'
              # Too many failed authentication attempts have been made on this account. This account is now locked out for 5 minutes.
              raise AccountLockedError, error_description
            else
              # Other error
              raise ApiError, error_description
          end
        end
      end
    rescue StandardError => e
      Rails.logger.error 'Error when executing a linkme API request: ' + e.to_s
      raise e
    end
  end

  # General error class
  class ApiError < StandardError
  end

  # linkme API error code 406: Method could not uniquely identify a record on which to operate.
  class NotFoundError < ApiError
  end

  # linkme API error code 501: Too many failed authentication attempts have been made on this account. This account is now locked out for 5 minutes.
  class AccountLockedError < ApiError
  end
end