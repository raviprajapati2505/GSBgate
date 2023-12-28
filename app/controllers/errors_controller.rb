class ErrorsController < ApplicationController
  def forbidden
    @status_code = 403
    @title = 'Forbidden'
    @message = 'You are not authorized to access this page.'
    render 'error', status: @status_code, layout: false
  end

  def not_found
    @status_code = 404
    @title = 'Page not found'
    @message = 'The page you were looking for doesn\'t exist. You may have mistyped the address or the page may have moved.'
    render 'error', status: @status_code, layout: false
  end

  def unprocessable_entity
    @status_code = 422
    @title = 'Unprocessable entity'
    @message = 'The change you wanted was rejected. Maybe you tried to change something you didn\'t have access to.'
    render 'error', status: @status_code, layout: false
  end

  def internal_server_error
    @status_code = 500
    @title = 'Internal server error'
    @message = 'We\'re sorry, but something went wrong. Please try again later.'
    render 'error', status: @status_code, layout: false
  end
end
