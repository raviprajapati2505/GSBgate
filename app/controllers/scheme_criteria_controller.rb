class SchemeCriteriaController < AuthenticatedController
  load_and_authorize_resource :scheme_criterion

  def index
    respond_to do |format|
      format.html {
        @page_title = 'Criteria'
        @datatable = Effective::Datatables::SchemeCriteria.new
        @datatable.current_ability = current_ability
        @datatable.table_html_class = 'table table-bordered table-striped table-hover'
      }
    end
  end

  def show
    @page_title = ERB::Util.html_escape(@scheme_criterion.full_name)
  end

  def update
    @scheme_criterion.scores = params[:scheme_criterion][:scores]
    if @scheme_criterion.update(scheme_criterion_params)
      redirect_to scheme_criterion_path(@scheme_criterion), notice: 'Criterion was successfully updated.'
    else
      render action: :edit, alert: 'Criterion could not be updated.'
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def scheme_criterion_params
    params.require(:scheme_criterion).permit(:name, :scores, :weight, :incentive_weight_minus_1, :incentive_weight_0, :incentive_weight_1, :incentive_weight_2, :incentive_weight_3, :incentive_weight)
  end
end