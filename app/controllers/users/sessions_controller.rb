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
        when 'users_admin', 'credentials_admin'
          redirect_path = users_path
        else
          redirect_path = after_sign_in_path_for(resource)
      end
      respond_with resource, location: redirect_path
    else
      sign_out(resource)
      redirect_to new_user_session_path, alert: "Account is not yet activated!"
    end
  end

   # custom functions for authentication as we introduced the OTP
  def check_authentication
    user = User.where('lower(email) = ? OR lower(username) = ?', params[:user][:username], params[:user][:username])
    if user.present?
      if user[0].active? 
        if user[0].valid_password?(params[:user][:password])
          # send OTP in email here and redirect to otp screen
          user[0].otp = rand 100..999
          user[0].save(validate: false)
          DigestMailer.send_otp_code_to_user(user[0]).deliver_now
          redirect_to send_otp_path(user[0].id)
        else
          sign_out(resource)
          redirect_to new_user_session_path, alert: "Incorrect Username or password"
        end
      else
        sign_out(resource)
        redirect_to new_user_session_path, alert: "Account is not yet activated!"
      end
    else
      sign_out(resource)
      redirect_to new_user_session_path, alert: "Incorrect Username or password"
    end
  end
   
  def otp
    @user = User.find(params[:id])
    @data = @user.id
  end

  def validate_otp
    user = User.find(params[:id])
    if User.is_service_provider(user)
      otp_field = params[:service_provider][:username].to_i
    else
      otp_field = params[:user][:username].to_i
    end
    if user.otp == otp_field
      warden.set_user(user)
      case user.role
        when 'default_role'
          redirect_path = dashboard_path
        when 'service_provider'
          redirect_path = dashboard_path
        when 'users_admin', 'credentials_admin'
          redirect_path = users_path
        else
          redirect_path = :root
      end
      redirect_to redirect_path
    else
      redirect_to send_otp_path(params[:id]), alert: "OTP entered did not match with the record, please enter correct OTP"
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
