class RegistrationsController < Devise::RegistrationsController
  # def create
  #   if verify_recaptcha
  #     super
  #   else
  #     build_resource(sign_up_params)
  #     clean_up_passwords(resource)
  #     flash.now[:alert] = 'There was an error with captcha code below, please retry.'
  #     flash.delete :recaptcha_error
  #     render :new
  #   end
  # end
end