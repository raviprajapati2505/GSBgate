class Api::ApiController < ApplicationController
  add_template_helper(ApiHelper)

  protect_from_forgery with: :null_session

  respond_to :json
  before_action :authenticate_user, :set_current_user
  before_action :authenticate_user!

  def not_found
    render json: {error: "No record found"}, status: 404
  end

  private

  def authenticate_user
    token = request.headers['Authorization']
    if token.present? && valid_jwt?(token)
      begin
          token = token.split
          jwt_payload = JWT.decode(token[1], Rails.application.config.devise_jwt_secret_key).first
          @current_user_id = jwt_payload['id']
          @current_user ||= User.find_by(id: @current_user_id)
        rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
        head :unauthorized
      end
    else
      head :unauthorized
    end
  end

  def authenticate_user!(options = {})
    head :unauthorized unless signed_in?
  end

  def signed_in?
    @current_user_id.present?
  end

  def valid_jwt?(token)
    JwtDenylist.find_by(jti: token).nil?
  end

  private
  def set_current_user
    User.current = @current_user
  end

end