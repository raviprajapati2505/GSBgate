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
