class UsersController < AuthenticatedController
  load_and_authorize_resource :user
  before_action :set_controller_model, except: [:new, :create, :index]

  def index
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
    @page_title = 'User Preferences'
  end

  def update_notifications
    begin
      NotificationTypesUser.transaction do
        # delete unchecked notification types
        @user.notification_types.each do |notification_types_user|
          unless params[:notification_types].any? {|id| id == notification_types_user.id}
            @user.notification_types.delete(notification_types_user)
            # NotificationTypesUser.delete(notification_types_user.id)
          end
        end
        # add new notification types
        params[:notification_types].each do |notification_type_id|
          unless @user.notification_types.any? {|type| type.id == notification_type_id}
            @user.notification_types << NotificationType.find(notification_type_id)
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
