class AuthenticatedController < ApplicationController
  layout 'layouts/authenticated'

  # before_action :authenticate!
  before_action :authenticate_user!
end
