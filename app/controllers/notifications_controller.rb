class NotificationsController < AuthenticatedController
  before_action :set_notification, only: [:update]
  load_and_authorize_resource

  def index
    @notifications = Notification.for_user(current_user).paginate page: params[:page], per_page: 5
  end

  def update
    @notification.read = true
    @notification.save
    render nothing: true
  end

  def update_all
    Notification.for_user(current_user).unread.update_all(read: true)
    render nothing: true
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_notification
    @notification = Notification.find(params[:id])
  end
end
