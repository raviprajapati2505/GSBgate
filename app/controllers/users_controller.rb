class UsersController < AuthenticatedController
  load_and_authorize_resource :user
  before_action :set_controller_model, except: [:index, :update_notifications]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :set_service_provider, only: [:edit_service_provider, :update_service_provider]

  def index
    @page_title = 'Users'
    @datatable = Effective::Datatables::Users.new
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @user, status: :ok }
    end
  end

  def edit
    unless @user.present? 
      redirect_to root_path, alert: "User is not available." and return
    end
  end

  def edit_service_provider
    unless @service_provider.present? 
      redirect_to root_path, alert: "Service Provider is not available." and return
    end
  end

  def update
    user_params = params.require(:user).permit(:name, :username, :employer_name, :linkme_user, :gord_employee, :cgp_license, :service_provider_id, :cgp_license_expiry_date, :cep_license, :cep_license_expired, :cep_license_expiry_date, :active, access_licences_attributes: [ :id, :userable_type, :userable_id, :licence_id, :expiry_date ] )

    if @user.update(user_params)
      redirect_to user_path(@user), notice: "User information successfully updated."
    else
      render :edit
    end
  end

  def update_service_provider
    service_provider_params = params.require(:service_provider).permit(:name, :username, :employer_name, :linkme_user, :gord_employee, :cgp_license, :cgp_license_expiry_date, :cep_license, :cep_license_expired, :cep_license_expiry_date, :active)

    if @service_provider.update(service_provider_params)
      redirect_to user_path(@user), notice: "Service Provider information successfully updated."
    else
      render :edit_service_provider
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

    redirect_to :root
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
          User.invite!(email: email)
          users = User.none
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
            result[:items][u.id][:error] = 'This user is not a GORD employee and cannot be added to the GSAS trust team.'
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

  private

  def set_controller_model
    @controller_model = @user
  end

  def set_user
    @user = User.find(params[:id])
  end

  def set_service_provider
    @service_provider = ServiceProvider.find(params[:id])
  end
end
