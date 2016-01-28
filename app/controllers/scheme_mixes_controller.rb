class SchemeMixesController < AuthenticatedController
  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project
  load_and_authorize_resource :scheme_mix, :through => :certification_path
  before_action :set_controller_model, except: [:new, :create]

  def show
    @page_title = @scheme_mix.full_name
  end

  def edit

  end

  def update
    if @scheme_mix.update(scheme_mix_params)
      redirect_to(project_certification_path_path(@project, @certification_path), notice: 'Successfully changed scheme name.')
    else
      redirect_to(project_certification_path_path(@project, @certification_path), alert: 'Failed to change scheme name.')
    end
  end

  private
  def set_controller_model
    @controller_model = @scheme_mix
  end

  def scheme_mix_params
    params.require(:scheme_mix).permit(:name)
  end
end
