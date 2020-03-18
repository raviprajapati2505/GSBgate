class SchemeCriteriaController < AuthenticatedController
  load_and_authorize_resource :scheme_criterion

  def index
    respond_to do |format|
      format.html {
        @page_title = 'Criteria'
        @datatable = Effective::Datatables::SchemeCriteria.new
      }
    end
  end

  def show
    @page_title = ERB::Util.html_escape(@scheme_criterion.full_name)
  end

  def update
    # Get all scores that are in use
    SchemeMixCriterion::TARGETED_SCORE_ATTRIBUTES.each_with_index do |targeted_score, index|
      used_targeted_scores = SchemeMixCriterion.where(scheme_criterion_id: @scheme_criterion.id).distinct.pluck(targeted_score.to_sym)
      used_submitted_scores = SchemeMixCriterion.where(scheme_criterion_id: @scheme_criterion.id).distinct.pluck(SchemeMixCriterion::SUBMITTED_SCORE_ATTRIBUTES[index].to_sym)
      used_achieved_scores = SchemeMixCriterion.where(scheme_criterion_id: @scheme_criterion.id).distinct.pluck(SchemeMixCriterion::ACHIEVED_SCORE_ATTRIBUTES[index].to_sym)

      all_used_scores = used_targeted_scores | used_submitted_scores | used_achieved_scores

      # Remove useless values
      params[:scheme_criterion][SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym].delete('') if params[:scheme_criterion][SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym].present?
      params[:scheme_criterion][SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym].delete(nil) if params[:scheme_criterion][SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym].present?
      all_used_scores.delete('')
      all_used_scores.delete(nil)

      # Check if there are removed scores that are in use
      removed_scores_in_use = []
      unless all_used_scores[0].nil?
        all_used_scores.each do |used_score|
          removed_scores_in_use << used_score unless params[:scheme_criterion][SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym].present? && params[:scheme_criterion][SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym].include?(used_score.to_s)
        end
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
        @scheme_criterion.send("#{SchemeCriterion::SCORE_ATTRIBUTES[index]}=", params[:scheme_criterion][SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym])
      end
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
    permitted_params = [:name]
    permitted_params += SchemeCriterion::SCORE_ATTRIBUTES
    permitted_params += SchemeCriterion::WEIGHT_ATTRIBUTES
    permitted_params += SchemeCriterion::INCENTIVE_MINUS_1_ATTRIBUTES
    permitted_params += SchemeCriterion::INCENTIVE_0_ATTRIBUTES
    permitted_params += SchemeCriterion::INCENTIVE_1_ATTRIBUTES
    permitted_params += SchemeCriterion::INCENTIVE_2_ATTRIBUTES
    permitted_params += SchemeCriterion::INCENTIVE_3_ATTRIBUTES
    permitted_params += [scheme_criterion_incentives_attributes: [:id, :incentive_weight, :label, :_destroy]]
    params.require(:scheme_criterion).permit(permitted_params)
  end
end