class SchemesController < AuthenticatedController
  load_and_authorize_resource :scheme

  def show
    @page_title = ERB::Util.html_escape(@scheme.name)
  end
end