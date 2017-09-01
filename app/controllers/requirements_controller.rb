class RequirementsController < AuthenticatedController
  before_action :set_requirement, only: [:edit, :update]
  load_and_authorize_resource

  def show
    @page_title = ERB::Util.html_escape(@requirement.name)
  end

  def edit
    @page_title = ERB::Util.html_escape(@requirement.name)
  end

  def update
    if @requirement.update(requirement_params)
      redirect_to requirement_path(@requirement), notice: 'Requirement was successfully updated.'
    else
      render action: :edit, alert: 'Requirement could not be updated.'
    end
  end

  private

  def set_requirement
    @controller_model = @requirement
  end

  def requirement_params
    params.require(:requirement).permit(:name)
  end

end