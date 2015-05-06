class AuthenticatedController < ApplicationController
  layout 'layouts/authenticated'

  before_action :authenticate_user!

  check_authorization unless: :devise_controller?
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to :back, alert: exception.message
  end
end
