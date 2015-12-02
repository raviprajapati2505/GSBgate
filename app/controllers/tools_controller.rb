require 'net/http'
require 'uri'

class ToolsController < AuthenticatedController
  authorize_resource :class => :tool

  def proxy
    uri = URI(Rails.configuration.x.tools_controller.url + @_request.fullpath)
    if @_request.request_method == 'GET'
      response = Net::HTTP.get_response(uri)
    elsif @_request.request_method == 'POST'
      response = Net::HTTP.post_form(uri, @_request.env['action_dispatch.request.request_parameters'])
    elsif @_request.request_method == 'PUT'
      response = Net::HTTP.put(uri, @_request.env['action_dispatch.request.request_parameters'])
    elsif @_request.request_method == 'DELETE'
      response = Net::HTTP.delete(uri)
    else
      raise('Unsupported request method')
    end

    respond_to do |format|
      format.json {
        render :json => response.body
      }
      format.html {
        render :html => response.body
      }
    end
  end
end
