class SchemeCriterionTextsController < AuthenticatedController
  before_action :set_scheme_criterion_text, only: [:edit, :update, :destroy]
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

  def new
    scheme_criterion = SchemeCriterion.find(params[:scheme_criterion_id])
    @page_title = 'New criterion text'
    @scheme_criterion_text = SchemeCriterionText.new(name: 'New text', visible: true, scheme_criterion: scheme_criterion)
    @controller_model = @scheme_criterion_text
  end

  def create
    @scheme_criterion_text = SchemeCriterionText.new(scheme_criterion_text_params)

    if @scheme_criterion_text.save
      redirect_to scheme_criterion_path(id: scheme_criterion_text_params[:scheme_criterion_id].to_i), notice: 'Criterion text was successfully created.'
    else
      render :new
    end
  end

  def destroy
    scheme_criterion = @scheme_criterion_text.scheme_criterion
    @scheme_criterion_text.destroy
    redirect_to scheme_criterion_path(scheme_criterion), notice: 'Criterion text was successfully destroyed.'
  end

  def sort
    params[:sort_order].each do |key, value|
      SchemeCriterionText.find(value[:id]).update_attribute(:display_weight, value[:display_weight])
    end
    render nothing: true
  end

  private

  def set_scheme_criterion_text
    @scheme_criterion_text = SchemeCriterionText.find(params[:id])
    @controller_model = @scheme_criterion_text
  end

  def scheme_criterion_text_params
    params.require(:scheme_criterion_text).permit(:name, :html_text, :visible, :scheme_criterion_id)
  end
end