class Api::SessionsController < Devise::SessionsController
  respond_to :json
  before_action :authenticate_user!, except: [:create]

  def create
    user = User.find_by_username(params[:user][:username])

    if user
      @current_user = user
      #response.headers['Authorization'] = "Bearer #{current_token}"
      #render json: {}, status: :ok
    else
      render json: { errors: { 'email or password' => ['is invalid'] } }, status: :unprocessable_entity
    end
  end

  def destroy
    JwtDenylist.find_or_create_by(jti: request.headers['Authorization']) if request.headers['Authorization']
    render json: { message: "signed out" }, status: 201
  end

  private

  def verify_signed_out_user
  end

  private
  def current_token
    request.headers['Authorization']
  end
end