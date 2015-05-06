class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      redirect_to :back, alert: exception.message
    else
      redirect_to new_user_session_path, alert: exception.message
    end

  end
end
