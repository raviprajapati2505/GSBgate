# An interface for the linkme.qa API, built on yourmembership.com.
# For more info on the API, see http://www.yourmembership.com/company/api-reference/
class LinkmeService
  require 'nokogiri'
  require 'faraday'

  attr_accessor :session_id
  attr_accessor :member_id

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

  # Auth.Authenticate
  # Authenticates a linkme.qa user. On success, the user will be assigned session_id.
  # Returns TRUE if successful, FALSE if unsuccessful. Raises an AccountLockedError when the account is locked.
  def auth_authenticate(username, password)
    endpoint = "/ams/authenticate"

    body = {
            usertype: 'Member',
            ClientID: Rails.application.config.x.linkme.client_id, 
            username: username, 
            password: password
    }.to_json
    
    headers = {
                'Content-Type' => 'application/json',
                'Accept' => 'application/json'
              }
              
    response = execute_api_request('POST', endpoint, headers, body)
    response = JSON.parse(response.env.response_body) 

    if (response["MemberID"].present? && response["SessionId"].present?)
      @member_id = response["MemberID"]
      @session_id = response["SessionId"]
      return true
    else
      return false
    end

  end

  # Member.Profile.Get
  # Retrieves the member profile of the linkme.qa user that is linked to the session_id.
  # Returns a hash containing the member info.
  def member_profile_get
    client_id = Rails.application.config.x.linkme.client_id
    endpoint = "/ams/#{client_id}/member/#{@member_id}/MemberProfile"

    body = {
      ClientID: client_id, 
      MemberID: @member_id
     }.to_json

     headers = {
      'Accept-Encoding' => 'none',
      'Accept' => 'application/json',
      'X-SS-ID' => @session_id
    }
  
    response = execute_api_request('GET', endpoint, headers, body)

    member_information = JSON.parse(response.env.response_body)
    member_information = flatten_hash(member_information)

    return Hash[ MEMBER_PROFILE_FIELDS.map{|key, value| [key, member_information[value&.to_sym]] } ]
  end

  # Sa.People.Profile.FindID
  # Retrieves a list of member profile ids of linkme.qa users by email.
  # Returns an array of member profile ids or raises a NotFoundError if no member ids were found.
  def sa_people_profile_findid(email)
    client_id = Rails.application.config.x.linkme.client_id
    new_api_url = Rails.application.config.x.linkme.new_api_url
    url = "#{new_api_url}/Ams/#{client_id}/PeopleProfileFindID"

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

  def execute_api_request(request_type = nil, endpoint = '', headers = {}, body = {})
    begin
      new_api_url = Rails.application.config.x.linkme.new_api_url
      url = new_api_url + endpoint

      if request_type == 'POST'
        response = Faraday.post(url) do |req|
          req.headers = headers
          req.body = body
        end
      else
        response = Faraday.get(url) do |req|
          req.headers = headers
          req.body = body
        end
      end

      if (response.body.blank? || response.status.blank?)
        raise ApiError, 'Invalid response'
      else
        error_code = response.status
        # Return response or handle error
        error_description = "API error #{error_code} #{response&.env&.reason_phrase}"
        case error_code
        when 200, 401
          return response
        when 406
          # Method could not uniquely identify a record on which to operate.
          raise NotFoundError, error_description
        when 501
          # Too many failed authentication attempts have been made on this account. This account is now locked out for 5 minutes.
          raise AccountLockedError, error_description
        else
          # Other error
          raise ApiError, error_description
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