class SchemesController < AuthenticatedController
  before_action :set_scheme, only: [:edit, :update]
  load_and_authorize_resource :scheme

  def show
    @page_title = ERB::Util.html_escape(@scheme.name)
  end

  def update
    if @scheme.update(scheme_params)
      redirect_to scheme_path(@scheme), notice: 'Scheme was successfully updated.'
    else
      render action: :edit, alert: 'Scheme could not be updated.'
    end
  end

  private

  def set_scheme
    @controller_model = @scheme
  end

  def scheme_params
    params.require(:scheme).permit(:name)
  end
end