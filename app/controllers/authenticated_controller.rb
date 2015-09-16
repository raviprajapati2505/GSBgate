class AuthenticatedController < ApplicationController
  layout 'layouts/authenticated'

  before_action :authenticate_user!

  check_authorization
  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    redirect_to forbidden_error_path
  end
end
