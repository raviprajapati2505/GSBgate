class Users::InvitationsController < Devise::InvitationsController
  before_action :configure_permitted_parameters

  # def new
  #   super
  # end

  # def create
  #   super
  # end

  # def edit
  #   super
  # end

  # def update
  #   super
  # end

  # protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:accept_invitation, keys: %i[name email username organization_name password password_confirmation])
  end
end
