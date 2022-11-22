class AuthenticatedController < ApplicationController
  layout 'layouts/authenticated'

  # before_action :authenticate!
  before_action :authenticate_user!, except: [:country_cities, :get_organization_details, :get_service_provider_by_domain, :country_code_from_name]
end
