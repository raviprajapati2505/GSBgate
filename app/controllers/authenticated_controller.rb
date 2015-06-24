class AuthenticatedController < ApplicationController
  layout 'layouts/authenticated'

  before_action :authenticate_user!

  check_authorization
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to forbidden_error_path
  end
end
