# An interface for the linkme.qa API, built on yourmembership.com.
# For more info on the API, see http://www.yourmembership.com/company/api-reference/
class LinkmeService
  require 'nokogiri'
  require 'faraday'

  attr_accessor :call_id
  attr_accessor :session_id

  # Fields that will be returned by the service
  # when an linkme member profile is requested.
  MEMBER_PROFILE_FIELDS = {
      id: 'CdbGUID',
      username: 'UserName',
      email: 'Email',
      picture: 'HeadshotImageURI',
      employer: 'EmployerName',
      name_prefix: 'Prefix',
      first_name: 'FirstName',
      middle_name: 'MiddleName',
      last_name: 'LastName',
      name_suffix: 'Suffix',
      membership: 'Membership',
      membership_expiry: 'MembershipExpiresDate'
  }

  PEOPLE_PROFILE_FIELDS = {
      id: 'CdbGUID',
      username: 'UserName',
      email: 'Email',
      picture: 'HeadshotImageURI',
      employer: 'EmployerName',
      name_prefix: 'Prefix',
      first_name: 'FirstName',
      middle_name: 'MiddleName',
      last_name: 'LastName',
      name_suffix: 'Suffix',
      membership: 'Membership',
      membership_expiry: 'MembershipExpiresDate',
      master_id: 'MasterID'
  }

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
  # Returns TRUE if successful, FALSE if unsuccessful. Raises an AccountLockedError when the account is locked.
  def auth_authenticate(username, password)
    begin
      new_api_url = Rails.application.config.x.linkme.new_api_url
      url = "#{new_api_url}/ams/authenticate"
      body = {
              usertype: 'Member',
              ClientID: Rails.application.config.x.linkme.client_id, 
              username: username, 
              password: password
            }.to_json
        
      response = Faraday.post(url) do |req|
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        req.body = body
      end
                
      return JSON.parse(response.body)
    rescue StandardError => e
      Rails.logger.error 'Error when executing a linkme API request: ' + e.to_s
      raise e
    end
  end

  # Member.Profile.Get
  # Retrieves the member profile of the linkme.qa user that is linked to the current API session.
  # Returns a hash containing the member info.
  def member_profile_get(member_id = nil, session_id = nil)
    client_id = Rails.application.config.x.linkme.client_id
    new_api_url = Rails.application.config.x.linkme.new_api_url
    url = "#{new_api_url}/ams/#{client_id}/member/#{member_id}/MemberProfile"

    body = {
      ClientID: client_id, 
      MemberID: member_id
     }.to_json

    response = Faraday.get(url) do |req|
      req.headers['X-SS-ID'] = session_id        
      req.headers['Accept'] = 'application/json'        
      req.headers['Accept-Encoding'] = 'none'        
      req.body = body        
    end 

    response = if (response.body.blank? || response.status.blank?)
                raise ApiError, 'Invalid response'
              elsif (response.status != 200)
                raise ApiError, "HTTP error #{response.status}"
              else
                member_information = JSON.parse(response.env.response_body)
                member_information = flatten_hash(member_information)
                Hash[ MEMBER_PROFILE_FIELDS.map{|key, value| [key, member_information[value&.to_sym]] } ]
              end
  end

  # Sa.People.Profile.FindID
  # Retrieves a list of member profile ids of linkme.qa users by email.
  # Returns an array of member profile ids or raises a NotFoundError if no member ids were found.
  def sa_people_profile_findid(email)
    client_id = Rails.application.config.x.linkme.client_id
    new_api_url = Rails.application.config.x.linkme.new_api_url
    url = "#{new_api_url}/Ams/#{client_id}/PeopleIDs"

    body = {
      Email: email, 
      SaPasscode: Rails.application.config.x.linkme.sa_passcode
     }.to_json
     
    response = Faraday.get(url) do |req|
      req.headers['Accept'] = 'application/json'        
      req.headers['Accept-Encoding'] = 'none'        
      req.body = body        
    end 
  end

  # Sa.People.Profile.Get
  def sa_people_profile_get(id)
    client_id = Rails.application.config.x.linkme.client_id
    new_api_url = Rails.application.config.x.linkme.new_api_url
    url = "#{new_api_url}/Ams/#{client_id}/PeopleProfileFindID"

    body = {
      ID: id, 
     }.to_json

    response = Faraday.get(url) do |req|
      req.headers['Accept'] = 'application/json'        
      req.headers['Accept-Encoding'] = 'none'        
      req.body = body        
    end 
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
      url = URI::HTTPS.build(host: Rails.application.config.x.linkme.api_url, path: '/')

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

  # to flatten all nested hash of member profile
  def flatten_hash(param, prefix = nil)
    param.each_pair.reduce({}) do |a, (k, v)|
      v.is_a?(Hash) ? a.merge(flatten_hash(v, "")) : a.merge("#{prefix}#{k}".to_sym => v)
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