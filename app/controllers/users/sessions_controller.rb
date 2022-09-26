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
        when 'credentials_admin'
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
    user = User.find_by(username: params[:user][:username])
    if user.present?
      if user.active?
        if user.valid_password?(params[:user][:password])
          # send OTP in email here and redirect to otp screen
          user.otp = 3.times.map{rand(10)}.join
          user.save(validate: false)
          DigestMailer.send_otp_code_to_user(user).deliver_now
          redirect_to send_otp_path(user.id)
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
    if user.otp == params[:user][:username].to_i
      warden.set_user(user)
      case user.role
        when 'default_role'
          redirect_path = dashboard_path
        when 'service_provider'
          redirect_path = dashboard_path
        when 'credentials_admin'
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
