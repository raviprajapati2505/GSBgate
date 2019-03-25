class Api::SessionsController < Api::ApiController

  # curl -v -H "Accept: application/json" -d "user%5Busername%5D=sas%40vito.be&user%5Bpassword%5D=Biljartisplezant456" "http://localhost:3000/api/sessions"
  def create
      # I guess this should be executed by Warden::JWTAuth::Middleware::TokenDispatcher
      response.headers['Authorization'] = "Bearer #{current_token}"
      render json: {}, status: :ok
  end

  # curl -v -H "Accept: application/json" -H "Authorization: Bearer <token>" -X "DELETE" http://localhost:3000/api/sessions
  def destroy
    # warden.logout
  end

  private
  def current_token
    request.env['warden-jwt_auth.token']
  end

end