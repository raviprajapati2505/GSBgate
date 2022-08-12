# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    if resource.active?
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      case resource.role
        when 'default_role'
          redirect_path = dashboard_path
        when 'service_provider'
          redirect_path = dashboard_path
        else
          redirect_path = after_sign_in_path_for(resource)
      end
      respond_with resource, location: redirect_path
    else
      sign_out(resource)
      redirect_to new_user_session_path, alert: "Account is not yet activated!"
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
