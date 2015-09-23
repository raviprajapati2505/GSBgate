class SchemeCriterionTextsController < AuthenticatedController
  before_action :set_scheme_criterion_text, only: [:edit, :update]
  load_and_authorize_resource

  def edit
    @page_title = "Edit #{@scheme_criterion_text.scheme_criterion.full_name} #{@scheme_criterion_text.name} text"
  end

  def update
    if @scheme_criterion_text.update(scheme_criterion_text_params)
      redirect_to scheme_criterion_path(@scheme_criterion_text.scheme_criterion), notice: 'Criterion text was successfully updated.'
    else
      render action: :edit, alert: 'Criterion text could not be updated.'
    end
  end

  private

  def set_scheme_criterion_text
    @scheme_criterion_text = SchemeCriterionText.find(params[:id])
    @controller_model = @scheme_criterion_text
  end

  def scheme_criterion_text_params
    params.require(:scheme_criterion_text).permit(:name, :html_text, :visible)
  end
end