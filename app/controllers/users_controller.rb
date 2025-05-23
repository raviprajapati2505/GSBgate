class UsersController < AuthenticatedController
  load_and_authorize_resource :user, except: [:country_cities, :get_organization_details, :get_corporate_by_domain, :country_code_from_name, :increase_demerit_flag, :confirm_destroy_cgp_user, :get_corporate_by_email]
  before_action :set_controller_model, except: [:index, :update_notifications]
  before_action :set_user, only: [:show, :edit, :update, :destroy, :download_user_files, :increase_demerit_flag, :confirm_destroy_cgp_user]
  before_action :set_corporate, only: [:edit_corporate, :update_corporate]

  def index
    @page_title = 'Users'
    @datatable = Effective::Datatables::Users.new(type: params.dig(:type) || 'all')
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @user, status: :ok }
    end
  end

  def edit
    if @user.role == 'corporate'
      @user_detail = CorporateDetail.find_or_initialize_by(id: @user.corporate_detail&.id)
    else
      @user_detail = UserDetail.find_or_initialize_by(id: @user.user_detail&.id)
    end
  
    unless @user.present? 
      redirect_to root_path, alert: "User is not available." and return
    end
  end

  def edit_corporate
    unless @corporate.present? 
      redirect_to root_path, alert: "Corporate is not available." and return
    end
  end

  def update
    user_params = 
      params.require(:user).permit(
        :name, 
        :email,
        :username,
        :profile_pic, 
        :organization_name, 
        :gord_employee, 
        :corporate_id, 
        :active,
        :name_suffix,
        :middle_name, 
        :last_name, 
        :email_alternate, 
        :role, 
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
        ],
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
        ],
        access_licences_attributes: [
          :id, 
          :user_id, 
          :licence_id, 
          :expiry_date, 
          :_destroy 
        ])

    if @user.update(user_params)
      redirect_to user_path(@user), notice: "User information successfully updated."
    else
      render :edit
    end
  end

  def update_corporate
    corporate_params = params.require(:corporate).permit(
      :name, 
      :username,
      :profile_pic,
      :organization_name, 
      :gord_employee, 
      :active,
      :name_suffix ,
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
      corporate_detail_attributes: [
            :id,
            :business_field,
            :portfolio,
            :commercial_licence_no,
            :commercial_licence_expiry_date,
            :commercial_licence_file,
            :accredited_corporate_licence_file,
            :demerit_acknowledgement_file,
            :cgp_licence_file,
            :energy_assessor_name, 
            :gsb_energey_assessment_licence_file,
            :nominated_cgp
        ]
      )

    if @corporate.update(corporate_params)
      redirect_to user_path(@user), notice: "Corporate information successfully updated."
    else
      render :edit_corporate
    end
  end

  def masquerade
    if params.has_key?(:user_id)
      user = User.find(params[:user_id])

      unless can?(:masquerade, user)
        raise CanCan::AccessDenied.new('Not Authorized.') and return
      end

      if user.blank?
        flash[:alert] = "Couldn't find the user."
      else
        warden.set_user(user)
        flash[:notice] = "You are now logged in as #{user.full_name}."
      end
    else
      flash[:alert] = 'No user id specified.'
    end

    case user.role
      when 'default_role'
        redirect_path = dashboard_path
      when 'corporate'
        redirect_path = dashboard_path
      when 'credentials_admin'
        redirect_path = users_path
      else
        redirect_path = :root
    end

    redirect_to redirect_path
  end

  def destroy
    begin
      if @user.destroy
        flash[:notice] = "User is successfully deleted"
      else
        flash[:alert] = 'User is failed to delete!'
      end

    rescue => e
      flash[:alert] = e.message

    ensure
      redirect_to(users_path)
    end
  end

  def list_notifications
    respond_to do |format|
      format.html {
        @page_title = 'User Preferences'
      }
      format.json {
        if params.has_key?(:project_id)
          items = NotificationType.select('notification_types.id as id, notification_types.project_level as project_level').for_user(@user.id).for_project(params[:project_id])
        else
          items = NotificationType.select('notification_types.id as id, notification_types.project_level as project_level').for_user(@user.id).for_project(nil)
        end
        render json: items
      }
    end
  end

  def update_notifications
    begin
      NotificationTypesUser.transaction do
        notification_types = NotificationType.all
        # project independent notification settings
        NotificationTypesUser.where(user: @user, project_id: nil).delete_all
        # delete checked notification types
        # params[:notification_types].each do |notification_type_id|
        #   if @user.notification_types.for_general_level.any? {|type| type.id == notification_type_id.to_i}
        #     NotificationTypesUser.where(user: @user, project_id: nil, notification_type_id: notification_type_id).delete_all
        #    end
        # end
        # add unchecked notification types
        notification_types.each do |notification_type|
          next unless params.key?(:notification_types) && params[:notification_types].present?
          unless params[:notification_types].any? { |id| id.to_i == notification_type.id }
            NotificationTypesUser.create!(user: @user, project_id: nil, notification_type_id: notification_type.id)
          end
        end

        # project dependent notification settings
        if params.has_key?(:project_id)
          NotificationTypesUser.where(user: @user, project_id: params[:project_id]).delete_all
          # delete checked notification types
          # params[:project_notification_types].each do |notification_type_id|
          #   if @user.notification_types.for_project(params[:project_id]).any? {|type| type.id == notification_type_id.to_i}
          #     NotificationTypesUser.where(user: @user, project_id: params[:project_id], notification_type_id: notification_type_id).delete_all
          #   end
          # end
          # add unchecked notification types
          notification_types.each do |notification_type|
            next unless notification_type.project_level && params.key?(:project_notification_types) && params[:project_notification_types].present?
            unless params[:project_notification_types].any? { |id| id.to_i == notification_type.id }
              # @user.notification_types_users << NotificationTypesUser.new(project_id: params[:project_id], notification_type_id: notification_type.id)
              NotificationTypesUser.create!(user: @user, project_id: params[:project_id], notification_type_id: notification_type.id)
            end
          end
        end
      end
      flash[:notice] = 'User preferences were successfully updated.'
    rescue Exception
      flash[:alert] = 'An error occured while updating user preferences.'
    end
    redirect_back(fallback_location: list_notifications_user_path)
  end

  def find_users_by_email
    check_gord_employee = params.has_key?(:gord_employee) && (params[:gord_employee] == '1')
    users = []
    existing_user_ids = []
    result = {items: {}, total_count: 0}

    if params.has_key?(:email)
      begin
        # Clean up the email address
        email = params[:email].squish.downcase

        user_exist = User.find_by_email(email).present?

        if user_exist
          if email.include?('+')
            users = User.where(email: email)
          else
            email_components = email.split('@')
            users = User.where("email ILIKE ALL ( array[:email_components] )", email_components: email_components.map! {|val| "%#{val}%" })
          end
        else
          User.invite!(email: email, gord_employee: check_gord_employee, name: email)
        end

        # Retrieve the ids of all users that are already linked to the project
        if params.has_key?(:project_id) && params.has_key?(:certification_team_type)
          existing_user_ids = ProjectsUser.where(project_id: params[:project_id], certification_team_type: params[:certification_team_type]&.to_i).pluck(:user_id)
        end

        # Add users to the json result
        users.each do |u|
          result[:items][u.id] = {}
          result[:items][u.id][:user_name] = u.full_name

          # Check if the user is already linked to the project
          if (existing_user_ids.include?(u.id))
            result[:items][u.id][:error] = 'This user is already linked to the project.'
          elsif !u.confirmed?
            result[:items][u.id][:error] = 'This user has not confirmed account yet.'
          elsif !u.active?
            result[:items][u.id][:error] = 'This user is deactivated.'
          elsif (check_gord_employee && !u.gord_employee?)
            # Check for gord_employee flag if required
            result[:items][u.id][:error] = 'This user is not a GORD employee and cannot be added to the GSB team.'
          end
        end

        # Count the users
        result[:total_count] = result[:items].count
      rescue StandardError => e
        result = {error: 'An error occurred when trying to find users by email. Please try again later.'}
      end
    end

    render json: result
  end

  def country_cities
    country_code = CS.countries.key(params["country"])
    country_states = CS.states(country_code)

    cities = []
    country_states.each { |k, v| cities << CS.cities(k) }

    cities = cities.flatten.uniq.sort
    cities_for = params["cities_for"]

    respond_to do |format|
      format.json { render json: {cities: cities, cities_for: cities_for} }
    end
  end

  def country_code_from_name
    country = ISO3166::Country[CS.countries.key(params["country"])]
    code = country ? country.country_code : 0
    respond_to do |format|
      format.json { render json: {code: code} }
    end
  end

  def get_organization_details
    corporate_id = params["corporate_id"]
    @user_details = User.find_by_id(corporate_id)
    respond_to do |format|
      format.json { render json: @user_details }
    end
  end

  def get_corporate_by_domain
    @corporates = Corporate.where("email ILIKE :organization_domain", organization_domain: "%#{params['domain_name']}%").pluck(Arel.sql('name, middle_name, last_name'), :id)
    
    respond_to do |format|
      format.json { render json: @corporates }
    end
  end

  def update_user_status
    status = @user.active?
  
    if @user.update_column(:active, !status)
      css_class = "success"
      message = "User status successfully updated!"
    else
      css_class = "error"
      message = "User status failed to update!"
    end

    render json: { css_class: css_class, message: message }
  end

  def download_user_files

    case params[:file]
      when "profile_pic"
        file = @user&.profile_pic&.path
      when "qid_file"
        file = @user.user_detail&.qid_file&.path
      when "university_credentials_file"
        file = @user.user_detail&.university_credentials_file&.path
      when "work_experience_file"
        file = @user.user_detail&.work_experience_file&.path
      when "cgp_licence_file"
        file = @user.corporate_detail&.cgp_licence_file&.path
      when "qid_work_permit_file"
        file = @user.user_detail&.qid_work_permit_file&.path
      when "gsb_energey_assessment_licence_file"
        file = @user.corporate_detail&.gsb_energey_assessment_licence_file&.path
      when "education_certificate"
        file = @user.user_detail&.education_certificate&.path
      when "other_documents"
        file = @user.user_detail&.other_documents&.path
      when "accredited_corporate_licence_file"
        file = @user.corporate_detail&.accredited_corporate_licence_file&.path
      when "commercial_licence_file"
        file = @user.corporate_detail&.commercial_licence_file&.path
      when "demerit_acknowledgement_file"
        file = @user.corporate_detail&.demerit_acknowledgement_file&.path
      when "application_form"
        file = @user.corporate_detail&.application_form&.path
      when "portfolio"
        file = @user.corporate_detail&.portfolio&.path
      when "gsb_notification"
        demerit_flag = DemeritFlag.find(params[:demerit_flag])
        file = demerit_flag&.gsb_notification&.path
      when "practitioner_acknowledge"
        demerit_flag = DemeritFlag.find(params[:demerit_flag])
        file = demerit_flag&.practitioner_acknowledge&.path
      when "licence_file"
        access_licence = AccessLicence.find(params[:access_licence_id])
        file = access_licence&.licence_file&.path
      else
        file = ''
      end
    send_file file, x_sendfile: false
  end

  def increase_demerit_flag
    demerit_flag = @user.demerit_flags.new
    @user.save(validate: false)

    redirect_to user_path(@user), notice: "Warning send to user successfully" and return
  end

  def confirm_destroy_cgp_user
    @user.corporate_id = nil
    @user.save(validate: false)
    redirect_to users_path, notice: "CGP/CEP removed from list successfully" and return
  end

  def get_corporate_by_email
    @corporates = Corporate.where(email: params['email']).pluck(Arel.sql("CONCAT(name, middle_name, last_name)"), :id)
    
    respond_to do |format|
      format.json { render json: @corporates }
    end
  end

  private

  def set_controller_model
    @controller_model = @user
  end

  def set_user
    @user = User.find(params[:id])
  end

  def set_corporate
    @corporate = Corporate.find(params[:id])
  end
end
