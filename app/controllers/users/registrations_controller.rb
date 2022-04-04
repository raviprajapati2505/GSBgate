# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  before_action :set_service_provider, only: [:edit_service_provider, :update_service_provider]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  def new_service_provider
    @service_provider = ServiceProvider.new
  end
  
  # POST /resource
  # def create
  #   super
  # end

  # POST /service_provider
  def create_service_provider
    @service_provider = ServiceProvider.new(sp_sign_up_params)
    @service_provider.role = :service_provider

    if @service_provider.save
      redirect_to new_user_session_path, notice: "Confirmation mail has been sent to your registered email address, Please verify your account."
    else
      clean_up_passwords @service_provider
      set_minimum_password_length
      render :new_service_provider
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # GET /edit_service_provider
  def edit_service_provider
    render :edit_service_provider
  end

  # PUT /resource
  # def update
  #   super
  # end

  # PUT /resource
  def update_service_provider
    sp_updated = update_resource(@service_provider, sp_update_params)
    if sp_updated
      redirect_to user_path(@service_provider), notice: "Confirmation mail sent to you registered email address, Please confirm your account."
    else
      clean_up_passwords resource
      set_minimum_password_length
      render :edit_service_provider
    end
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name email username employer_name password password_confirmation])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name email username linkme_user gord_employee cgp_license cgp_license_expired employer_name active password password_confirmation current_password])
  end

  def sp_sign_up_params
    params.require(:service_provider).permit(%i[name email username employer_name password password_confirmation])
  end

  def sp_update_params
    params.require(:service_provider).permit(%i[name email username linkme_user gord_employee cgp_license cgp_license_expired employer_name active password password_confirmation current_password])
  end

  def set_service_provider
    @service_provider = ServiceProvider.find(params[:id])
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(_resource)
    new_user_session_path
  end
end
