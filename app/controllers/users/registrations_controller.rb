# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  before_action :set_corporate, only: [:edit_corporate, :update_corporate]
  before_action :set_user, only: [:edit]

  # GET /resource/sign_up
  def new
    super do |user|
      user.build_user_detail
    end
  end

  def new_corporate
    @corporate = Corporate.new
    @corporate_detail = @corporate.build_corporate_detail
  end
  
  # POST /resource
  # def create
  #   super
  # end

  # POST /corporate
  def create_corporate
    @corporate = Corporate.new(sp_sign_up_params)
    @corporate.role = :corporate

    if @corporate.save
      redirect_to new_user_session_path, notice: "Confirmation mail has been sent to your registered email address, Please verify your account."
    else
      clean_up_passwords @corporate
      set_minimum_password_length
      render :new_corporate
    end
  end

  # GET /resource/edit
  def edit
    @user_detail = UserDetail.find_or_initialize_by(id: @user.user_detail&.id)
    super
  end

  # GET /edit_corporate
  def edit_corporate
    @corporate_detail = CorporateDetail.find_or_initialize_by(id: @corporate.corporate_detail&.id)
    render :edit_corporate
  end

  # PUT /resource
  # def update
  #  super
  # end

  # PUT /resource
  def update_corporate
    #sp_update_params[:corporate_detail_attributes][:commercial_licence_file] = @corporate.corporate_detail.commercial_licence_file unless sp_update_params[:corporate_detail_attributes].has_key?(:commercial_licence_file) && sp_update_params[:corporate_detail_attributes][:commercial_licence_file].present?
    sp_updated = update_resource(@corporate, sp_update_params)
    if sp_updated
      redirect_to user_path(@corporate), notice: "Profile has successfully updated."
    else
      clean_up_passwords resource
      set_minimum_password_length
      render :edit_corporate
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
    devise_parameter_sanitizer.permit(:sign_up, keys: [
        :name, 
        :email,
        :profile_pic,
        :username, 
        :organization_name, 
        :gord_employee, 
        :corporate_id, 
        :password, 
        :password_confirmation, 
        :name_suffix, 
        :middle_name, 
        :last_name, 
        :email_alternate,
        :country, 
        :city, 
        :mobile_area_code, 
        :mobile,
        :organization_email,
        :organization_address, 
        :organization_country, 
        :organization_city, 
        :organization_website, 
        :organization_phone_area_code, 
        :organization_phone, 
        :organization_fax_area_code, 
        :organization_fax, 
        :gsb_id,
        :practitioner_accreditation_type,
        user_detail_attributes: [ 
          :gender, 
          :dob,
          :designation, 
          :work_experience, 
          :qid_or_passport_number, 
          :qid_file,
          :qid_file_cache,
          :university_credentials_file, 
          :work_experience_file, 
          :cgp_licence_file, 
          :qid_work_permit_file, 
          :energy_assessor_name, 
          :gsb_energey_assessment_licence_file,
          :education,
          :education_certificate,
          :other_documents
        ]
    ])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [
        :name, 
        :email, 
        :profile_pic,
        :username, 
        :organization_name, 
        :gord_employee,
        :corporate_id, 
        :password,
        :current_password,
        :password_confirmation, 
        :name_suffix, 
        :middle_name, 
        :last_name, 
        :email_alternate,
        :country, 
        :city, 
        :mobile_area_code, 
        :mobile,
        :organization_email,
        :organization_address, 
        :organization_country, 
        :organization_city, 
        :organization_website, 
        :organization_phone_area_code, 
        :organization_phone, 
        :organization_fax_area_code, 
        :organization_fax, 
        :gsb_id,
        :practitioner_accreditation_type,
        user_detail_attributes: [
          :id, 
          :gender, 
          :dob,
          :designation, 
          :work_experience, 
          :qid_or_passport_number, 
          :qid_file,
          :qid_file_cache,
          :university_credentials_file, 
          :work_experience_file, 
          :cgp_licence_file, 
          :qid_work_permit_file, 
          :energy_assessor_name, 
          :gsb_energey_assessment_licence_file,
          :education,
          :education_certificate,
          :other_documents
        ]
    ])
  end

  def sp_sign_up_params
      params.require(:corporate).permit([
        :name, 
        :email,
        :profile_pic, 
        :username, 
        :organization_name, 
        :password, 
        :password_confirmation, 
        :name_suffix, 
        :middle_name, 
        :last_name, 
        :email_alternate,
        :country, 
        :city, 
        :mobile_area_code, 
        :mobile,
        :organization_email,
        :organization_address, 
        :organization_country, 
        :organization_city, 
        :organization_website, 
        :organization_phone_area_code, 
        :organization_phone, 
        :organization_fax_area_code, 
        :organization_fax, 
        :gsb_id,
        :practitioner_accreditation_type,
        corporate_detail_attributes: [
          :business_field,
          :portfolio,
          :commercial_licence_no,
          :commercial_licence_expiry_date,
          :commercial_licence_file,
          :accredited_corporate_licence_file,
          :demerit_acknowledgement_file,
          :application_form,
          :cgp_licence_file,
          :energy_assessor_name, 
          :gsb_energey_assessment_licence_file,
          :nominated_cgp,
          :exam,
          :workshop
        ]
    ])
  end

  def sp_update_params
    params.require(:corporate).permit([
            :name, 
            :email,
            :profile_pic, 
            :username, 
            :organization_name, 
            :password,
            :current_password,
            :password_confirmation, 
            :name_suffix, 
            :middle_name, 
            :last_name, 
            :email_alternate,
            :country, 
            :city, 
            :mobile_area_code, 
            :mobile,
            :organization_email,
            :organization_address, 
            :organization_country, 
            :organization_city, 
            :organization_website, 
            :organization_phone_area_code, 
            :organization_phone, 
            :organization_fax_area_code, 
            :organization_fax, 
            :gsb_id,
            :practitioner_accreditation_type, 
            corporate_detail_attributes: [
              :id,
              :business_field,
              :portfolio,
              :commercial_licence_no,
              :commercial_licence_expiry_date,
              :commercial_licence_file,
              :accredited_corporate_licence_file,
              :demerit_acknowledgement_file,
              :application_form,
              :cgp_licence_file,
              :energy_assessor_name, 
              :gsb_energey_assessment_licence_file,
              :nominated_cgp
            ]
      ])
  end

  def set_corporate
    @corporate = Corporate.find(params[:id])
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(_resource)
    new_user_session_path
  end

  def set_user
    @user = User.find(params[:format])
  end

  protected

  def after_update_path_for(resource)
    user_path(resource)
  end
end
