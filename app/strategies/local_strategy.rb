# A Warden strategy to authenticate local DB users
class LocalStrategy < BaseStrategy
  def authenticate!
    # Fetch the form params
    user_data = params.fetch('user', {})

    # Check if the user exists in the GSAS DB
    user = User.local_users.find_by_username(user_data['username'])

    # User exists?
    if user.nil?
      # Sets the strategy to fail. Will cascade to the next strategy.
      fail 'Your username is unknown.'
    # Password correct?
    elsif (user.password != user_data['password'])
      # Sets the strategy to fail. Causes a halt!. Halts cascading of strategies. Makes this one the last one processed.
      fail! 'Your username or password was incorrect.'
    else
      # Update user sign in statistics
      user.log_sign_in

      # Save the user
      user.save!

      # Log the user in
      success! user
    end
  end
end
