class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery unless: -> { request.format.json? }
  protect_from_forgery with: :exception, prepend: true

  before_action :init
  before_action :set_current_user

  helper_method :warden, :user_signed_in?, :current_user

  def user_signed_in?
    !current_user.nil?
  end

  def current_user
    warden.user
  end

  def authenticate!
    warden.authenticate!
  end

  def warden
    request.env['warden']
  end

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    redirect_to forbidden_error_path
  end

  rescue_from Effective::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    redirect_to forbidden_error_path
  end

  private
  def init
    # Set default page title
    @page_title = 'GSASgate'
  end

  def set_current_user
    User.current = current_user
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, params, request)
  end
end