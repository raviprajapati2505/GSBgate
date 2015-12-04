class UsersController < AuthenticatedController
  load_and_authorize_resource :user
  before_action :set_controller_model, except: [:new, :create, :index, :update_notifications]

  def index
    @page_title = 'Users'
  end

  def new
    @page_title = 'Add user'
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    # Generate a random password, this will be changed by the user later
    @user.password = Devise.friendly_token.first(20)

    if @user.save
      redirect_to users_path, notice: 'User account was successfully created. The user will be notified by email.'
    else
      flash[:alert] = 'An error occurred when creating the user account, please try again later.'
      render :new
    end
  end

  def edit
    @page_title = "Edit user #{@user.email}"
  end

  def update
    if @user.update_without_password(user_params)
      redirect_to users_path, notice: 'Successfully updated user.'
    else
      render action: 'edit'
    end
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
            unless params[:notification_types].any? {|id| id.to_i == notification_type.id}
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
              unless params[:project_notification_types].any? {|id| id.to_i == notification_type.id}
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

  private

  def set_controller_model
    @controller_model = @user
  end

  def user_params
    params.require(:user).permit(:email, :role)
  end
end
