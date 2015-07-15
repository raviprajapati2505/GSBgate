class AuthenticatedController < ApplicationController
  layout 'layouts/authenticated'

  before_action :authenticate_user!

  check_authorization
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to forbidden_error_path
  end

  # Creates a notification for a user
  def notify(body: '', body_params: [], uri: '', user: nil, project: nil)
    unless (user == current_user)
      Notification.create(body: body.gsub('%s', '<span class="keyword">%s</span>') % body_params, uri: uri, user: user, project: project)
    end
  end
end
