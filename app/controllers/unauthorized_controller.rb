class UnauthorizedController < ActionController::Metal
  include ActionController::UrlFor
  include ActionController::Redirecting
  include Rails.application.routes.url_helpers
  include Rails.application.routes.mounted_helpers

  delegate :flash, :to => :request

  def self.call(env)
    @respond ||= action(:respond)
    @respond.call(env)
  end

  def respond
    unless request.get?
      # message = request.env['warden.options'].fetch(:message, "unauthorized.user")
      flash.alert = "Unauthorized user."
    end

    redirect_to new_user_session_path
  end
end