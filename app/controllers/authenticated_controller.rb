class AuthenticatedController < ApplicationController
  layout 'layouts/authenticated'

  prepend_before_filter :authenticate!
end
