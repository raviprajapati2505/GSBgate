class UsersController < AuthenticatedController
  load_and_authorize_resource :user
  before_action :set_controller_model, except: [:index, :update_notifications]

  def index
    @page_title = 'Users'
  end

  def show
    respond_to do |format|
      format.json { render json: @user, status: :ok }
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
        NotificationTypesUser.delete_all(user: @user, project_id: nil)
        # delete checked notification types
        # params[:notification_types].each do |notification_type_id|
        #   if @user.notification_types.for_general_level.any? {|type| type.id == notification_type_id.to_i}
        #     NotificationTypesUser.delete_all(user: @user, project_id: nil, notification_type_id: notification_type_id)
        #    end
        # end
        # add unchecked notification types
        notification_types.each do |notification_type|
          unless notification_type.project_level
            unless params[:notification_types].any? { |id| id.to_i == notification_type.id }
              NotificationTypesUser.create!(user: @user, project_id: nil, notification_type_id: notification_type.id)
            end
          end
        end

        # project dependent notification settings
        if params.has_key?(:project_id)
          NotificationTypesUser.delete_all(user: @user, project_id: params[:project_id])
          # delete checked notification types
          # params[:project_notification_types].each do |notification_type_id|
          #   if @user.notification_types.for_project(params[:project_id]).any? {|type| type.id == notification_type_id.to_i}
          #     NotificationTypesUser.delete_all(user: @user, project_id: params[:project_id], notification_type_id: notification_type_id)
          #   end
          # end
          # add unchecked notification types
          notification_types.each do |notification_type|
            if notification_type.project_level
              unless params[:project_notification_types].any? { |id| id.to_i == notification_type.id }
                # @user.notification_types_users << NotificationTypesUser.new(project_id: params[:project_id], notification_type_id: notification_type.id)
                NotificationTypesUser.create!(user: @user, project_id: params[:project_id], notification_type_id: notification_type.id)
              end
            end
          end
        end
      end
      flash[:notice] = 'User preferences were successfully updated.'
    rescue Exception
      flash[:alert] = 'An error occured while updating user preferences.'
    end
    redirect_to :back
  end

  def find_users_by_email
    result = {items: {}, total_count: 0}

    begin
      if params.has_key?(:email)
        # Clean up the email address
        email = params[:email].squish.downcase

        # Create a linkme.qa service object
        linkme = LinkmeService.new

        # Find linkme member(s) by email
        linkme_member_ids = linkme.sa_people_profile_findid(email)

        # Loop the found users
        linkme_member_ids.each do |linkme_member_id|
          # Retrieve the user's linkme member profile
          member_profile = linkme.sa_people_profile_get(linkme_member_id)

          # Update or create the linkme user in the DB
          user = User.update_or_create_linkme_user!(member_profile)

          # Add the user id to the result
          result[:items][user.id] = user.full_name
        end

        # Find local DB users by email
        local_users = User.local_users.where(email: email)

        # Add the local user ids to the result
        local_users.each do |local_user|
          result[:items][local_user.id] = local_user.full_name
        end

        # Count the users
        result[:total_count] = result[:items].count
      end
    rescue LinkmeService::NotFoundError
      # Do nothing
    rescue LinkmeService::ApiError
      result = {error: 'An error occurred when trying to find users by email. Please try again later.'}
    end

    render json: result
  end

  private
  def set_controller_model
    @controller_model = @user
  end
end
