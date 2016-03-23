# A Warden strategy to authenticate users via the linkme.qa API
class LinkmeStrategy < BaseStrategy
  def authenticate!
    begin
      # Fetch the form params
      user_data = params.fetch('user', {})

      # Create a linkme.qa service object
      linkme = LinkmeService.new

      # Create an API session
      linkme.session_create

      # Authenticate the user
      if (linkme.auth_authenticate(user_data['username'], user_data['password']))
        # Get the linkme member profile
        member_profile = linkme.member_profile_get

        # Check if the user exists in the GSAS DB
        user = User.linkme_users.find_by_linkme_member_id(member_profile[:id])

        # If the user record doesn't exist, create it
        user ||= User.new

        # Update the user's data from linkme.qa
        user.linkme_member_id = member_profile[:id]
        user.username = member_profile[:username]
        user.email = member_profile[:email]
        user.cgp_license = (member_profile[:membership] == 'Practitioner - Certificate')
        user.gsas_trust_team = (member_profile[:employer] == 'GORD')

        # Update user sign in statistics
        user.log_sign_in

        # Save the user
        user.save!

        # Log the user in
        success! user
      else
        # Linkme credentials NOT OK
        fail 'Your linkme.qa username or password was incorrect.'
      end

      # Abandon the linkme API session
      linkme.session_abandon
    rescue LinkmeService::AccountLockedError
      fail 'Too many failed authentication attempts have been made on this account. This account is now locked out for 5 minutes.'
    rescue LinkmeService::ApiError
      fail 'An error occurred when trying to log in, please try again later. If this problem persists, please contact an administrator.'
    end
  end
end
