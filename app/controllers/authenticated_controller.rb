class AuthenticatedController < ApplicationController
  layout 'layouts/authenticated'

  before_action :authenticate_user!
  before_action :set_current_user

  # https://github.com/CanCanCommunity/cancancan/wiki/Ensure-Authorization
  check_authorization :unless => :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    redirect_to forbidden_error_path
  end

  rescue_from Effective::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    redirect_to forbidden_error_path
  end

  def set_current_user
    User.current = current_user
  end
end
