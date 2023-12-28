class Api::V1::CountriesController < Api::ApiController

  # curl -v -H "Accept: application/json" -d "user%5Busername%5D=sas%40vito.be&user%5Bpassword%5D=Biljartisplezant456" "http://localhost:3000/api/sessions"
  def index
    @countries = CS.countries.sort_by{|_key, value| value }.to_h
    render 'index', formats: :json
  end

end