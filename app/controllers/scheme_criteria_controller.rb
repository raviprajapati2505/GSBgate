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
    # Get all scores that are in use
    used_targeted_scores = SchemeMixCriterion.where(scheme_criterion_id: @scheme_criterion.id).distinct.pluck(:targeted_score)
    used_submitted_scores = SchemeMixCriterion.where(scheme_criterion_id: @scheme_criterion.id).distinct.pluck(:submitted_score)
    used_achieved_scores = SchemeMixCriterion.where(scheme_criterion_id: @scheme_criterion.id).distinct.pluck(:achieved_score)
    all_used_scores = used_targeted_scores | used_submitted_scores | used_achieved_scores

    # Check if there are removed scores that are in use
    removed_scores_in_use = []
    all_used_scores.each do |used_score|
      removed_scores_in_use << used_score unless params[:scheme_criterion][:scores].include?(used_score.to_s)
    end

    # Notify the user if there are scores in use that he tried to remove
    if removed_scores_in_use.count > 0
      if (removed_scores_in_use.count == 1)
        error_message = "Score #{removed_scores_in_use[0].to_i} cannot be removed because it's already in use."
      else
        error_message = "Scores #{removed_scores_in_use.map { |score| score.to_i }.to_sentence} cannot be removed because they are already in use."
      end
      redirect_to scheme_criterion_path(@scheme_criterion), alert: "Criterion could not be updated. #{error_message}"
      return
    else
      @scheme_criterion.scores = params[:scheme_criterion][:scores]
    end

    if @scheme_criterion.update(scheme_criterion_params)
      redirect_to scheme_criterion_path(@scheme_criterion), notice: 'Criterion was successfully updated.'
    else
      redirect_to scheme_criterion_path(@scheme_criterion), alert: 'Criterion could not be updated.'
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def scheme_criterion_params
    params.require(:scheme_criterion).permit(:name, :scores, :scores_b, :weight, :weight_b, :incentive_weight_minus_1, :incentive_weight_minus_1_b, :incentive_weight_0, :incentive_weight_0_b, :incentive_weight_1, :incentive_weight_1_b, :incentive_weight_2, :incentive_weight_2_b, :incentive_weight_3, :incentive_weight_3_b)
  end
end