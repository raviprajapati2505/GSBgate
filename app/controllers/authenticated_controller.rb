class AuthenticatedController < ApplicationController
  layout 'layouts/authenticated'

  # before_action :authenticate!
  before_action :authenticate_user!, except: [:country_cities, :country_code_from_name]
end
