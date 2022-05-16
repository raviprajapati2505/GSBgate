class AuthenticatedController < ApplicationController
  layout 'layouts/authenticated'

  # before_action :authenticate!
  before_action :authenticate_user!, except: [:country_cities, :get_organization_details]
end
