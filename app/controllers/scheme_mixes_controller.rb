class SchemeMixesController < AuthenticatedController
  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project
  load_and_authorize_resource :scheme_mix, :through => :certification_path
  before_action :set_controller_model, except: [:new, :create]

  def show
    @page_title = @scheme_mix.full_name
  end

  private
  def set_controller_model
    @controller_model = @scheme_mix
  end
end
