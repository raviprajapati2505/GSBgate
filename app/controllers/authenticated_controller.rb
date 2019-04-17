class AuthenticatedController < ApplicationController
  layout 'layouts/authenticated'

  before_action :authenticate!
end
