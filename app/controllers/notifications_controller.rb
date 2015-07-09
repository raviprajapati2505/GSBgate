class NotificationsController < AuthenticatedController
  load_and_authorize_resource

  def index
    @notifications = Notification.for_user(current_user).paginate page: params[:page], per_page: 2
    @notifications.each do |notification|
      notification.read = true
      notification.save
    end
  end
end
