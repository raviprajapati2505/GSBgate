class UsersController < AuthenticatedController
  load_and_authorize_resource :user
  before_action :set_controller_model, except: [:index, :update_notifications]

  def index
    @page_title = 'Users'
    @datatable = Effective::Datatables::Users.new
  end

  def show
    respond_to do |format|
      format.json { render json: @user, status: :ok }
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
        begin
          # Clean up the email address
          email = params[:email].squish.downcase

          # Create a linkme.qa service object
          linkme = LinkmeService.new

          # Find linkme member(s) by email
          linkme_member_ids_hash = linkme.sa_people_profile_findid(email)

          # Loop the found users
          linkme_member_ids_hash.each do |member_id, profile_id|
            # Retrieve the user's linkme member profile
            member_profile = linkme.sa_people_profile_get(profile_id)
            member_profile[:id] = member_id

            # people_profile = linkme.sa_people_profile_get(member_profile[:id])
            # master_profile = linkme.sa_people_profile_get(people_profile[:master_id]) unless people_profile[:master_id].blank?

            # Update or create the linkme user in the DB
            user = User.update_or_create_linkme_user!(member_profile)

            users << user
          end
        rescue LinkmeService::NotFoundError
          # Do nothing if the user wasn't found in the linkme DB
        end

        # Find local DB users by email and add them to the array
        users = users + User.local_users.where(email: email)

        # Retrieve the ids of all users that are already linked to the project
        if params.has_key?(:project_id)
          existing_user_ids = ProjectsUser.where(project_id: params[:project_id]).pluck(:user_id)
        end

        # Add users to the json result
        users.each do |u|
          result[:items][u.id] = {}
          result[:items][u.id][:user_name] = u.full_name

          # Check if the user is already linked to the project
          if (existing_user_ids.include?(u.id))
            result[:items][u.id][:error] = 'This user is already linked to the project.'
            # Check for gord_employee flag if required
          elsif (check_gord_employee && !u.gord_employee?)
            result[:items][u.id][:error] = 'This user is not a GORD employee and cannot be added to the GSAS trust team.'
          end
        end

        # Count the users
        result[:total_count] = result[:items].count
      rescue LinkmeService::ApiError
        result = {error: 'An error occurred when trying to find users by email. Please try again later.'}
      end
    end

    render json: result
  end

  private
  def set_controller_model
    @controller_model = @user
  end
end
