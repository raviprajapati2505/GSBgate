class Api::ApiController < ActionController::API
  add_template_helper(ApiHelper)

  # protect_from_forgery with: :null_session
  
  skip_forgery_protection
  
  prepend_before_action :authenticate!

  before_action :set_current_user

  helper_method :warden, :user_signed_in?, :current_user

  def user_signed_in?
    !current_user.nil?
  end

  def current_user
    warden.user
  end

  def authenticate!
    warden.authenticate!
  end

  def warden
    request.env['warden']
  end

  private
  def set_current_user
    User.current = current_user
  end

end