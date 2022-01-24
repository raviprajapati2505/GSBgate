# A Warden strategy to authenticate users via the linkme.qa API
class LinkmeStrategy < BaseStrategy
  def authenticate!
    begin
      # Fetch the form params
      user_data = params.fetch('user', {})

      # Create a linkme.qa service object
      linkme = LinkmeService.new

      # Create an API session
      # linkme.session_create

      # Authenticate the user
      
      response = linkme.auth_authenticate(user_data['username'], user_data['password'])
      
      if ((response["MemberID"].present? && response["SessionId"].present?))
        # Get the linkme member profile
        member_profile = linkme.member_profile_get(response["MemberID"], response["SessionId"])

        people_profile = linkme.sa_people_profile_get(member_profile[:member_id])
        master_profile = linkme.sa_people_profile_get(people_profile[:master_id]) unless people_profile[:master_id].blank?

        # Update or create the linkme.qa user in the GSAS DB
        user = User.update_or_create_linkme_user!(member_profile)

        # Update user sign in statistics
        user.log_sign_in

        # Save the user
        user.save!

        # Log the user in
        success! user
      else
        # Linkme credentials NOT OK
        fail 'The username and password you entered do not match. Forgot your username or password? <a href="http://www.linkme.qa/general/email_pass.asp" target="_blank">Please click here.</a>'
      end

    rescue LinkmeService::AccountLockedError
      fail 'Too many failed authentication attempts have been made on this account. This account is now locked out for 5 minutes.'
    rescue LinkmeService::ApiError
      fail 'An error occurred when trying to log in, please try again later. If this problem persists, please contact an administrator.'
    end
  end
end
