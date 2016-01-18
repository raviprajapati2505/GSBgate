class SchemeMixCriteriaController < AuthenticatedController
  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project
  load_and_authorize_resource :scheme_mix, :through => :certification_path
  load_and_authorize_resource :scheme_mix_criterion, :through => :scheme_mix
  # don't load the resource for the list action, as it uses a custom query
  skip_load_and_authorize_resource :scheme_mix, only: [:list]
  skip_load_and_authorize_resource :scheme_mix_criterion, only: [:list]
  # skip default update_score authorization, as we have manually created authorization levels per score type
  skip_authorize_resource :scheme_mix_criterion, only: :update_scores
  before_action :set_controller_model, except: [:new, :create, :list]

  def show
    respond_to do |format|
      format.html {
        @page_title = @scheme_mix_criterion.scheme_criterion.full_name
        @prev_smc = @scheme_mix_criterion.previous_scheme_mix_criterion
        @next_smc = @scheme_mix_criterion.next_scheme_mix_criterion
      }
      format.json { render json: {id: @scheme_mix_criterion.scheme_mix.id.to_s + ';' + @scheme_mix_criterion.id.to_s, name: @scheme_mix_criterion.full_name}, status: :ok }
    end
  end

  def edit_status
  end

  def update_status
    todos = @scheme_mix_criterion.todo_before_status_advance

    if todos.blank?
      if @scheme_mix_criterion.submitting?
        status = :submitted
      elsif @scheme_mix_criterion.submitting_after_appeal?
        status = :submitted_after_appeal
      elsif @scheme_mix_criterion.verifying?
        if params.has_key?(:achieved)
          status = :submitted_score_achieved
        else
          status = :submitted_score_not_achieved
        end
      elsif @scheme_mix_criterion.verifying_after_appeal?
        if params.has_key?(:achieved)
          status = :submitted_score_achieved_after_appeal
        else
          status = :submitted_score_not_achieved_after_appeal
        end
      elsif @scheme_mix_criterion.submitted? && [CertificationPathStatus::SUBMITTING, CertificationPathStatus::SUBMITTING_AFTER_SCREENING, CertificationPathStatus::SUBMITTING_PCR].include?(@certification_path.certification_path_status_id)
        status = :submitting
      elsif @scheme_mix_criterion.submitted_after_appeal? && @certification_path.certification_path_status_id == CertificationPathStatus::SUBMITTING_AFTER_APPEAL
        status = :submitting_after_appeal
      elsif (@scheme_mix_criterion.submitted_score_achieved? || @scheme_mix_criterion.submitted_score_not_achieved?) && @certification_path.certification_path_status_id == CertificationPathStatus::VERIFYING
        status = :verifying
      elsif (@scheme_mix_criterion.submitted_score_achieved_after_appeal? || @scheme_mix_criterion.submitted_score_not_achieved_after_appeal?) && @certification_path.certification_path_status_id == CertificationPathStatus::VERIFYING_AFTER_APPEAL
        status = :verifying_after_appeal
      end

      if status.present?
        @scheme_mix_criterion.status = status
        @scheme_mix_criterion.audit_log_user_comment = params[:scheme_mix_criterion][:audit_log_user_comment]
        @scheme_mix_criterion.save!

        flash[:notice] = 'Criterion status was sucessfully updated.'
      else
        flash[:alert] = 'The criterion status cannot be updated.'
      end
    else
      flash[:alert] = todos.first
    end

    redirect_to project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion)
  end

  def update_scores
    authorize! :update_targeted_score, @scheme_mix_criterion, message: 'Not authorized to update targeted score' if scheme_mix_criterion_params.has_key?(:targeted_score)
    authorize! :update_submitted_score, @scheme_mix_criterion, message: 'Not authorized to update submitted score' if scheme_mix_criterion_params.has_key?(:submitted_score)
    authorize! :update_achieved_score, @scheme_mix_criterion, message: 'Not authorized to update achieved score' if scheme_mix_criterion_params.has_key?(:achieved_score)

    redirect_path = project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion)
    min_valid_score = @scheme_mix_criterion.scheme_criterion.minimum_valid_score

    # If not attempting this criterion, set submitted score to minimum valid score
    if scheme_mix_criterion_params.has_key?(:targeted_score) && (params[:scheme_mix_criterion][:targeted_score].to_i == min_valid_score)
      params[:scheme_mix_criterion][:submitted_score] = params[:scheme_mix_criterion][:targeted_score]
    end

    # The targeted & submitted scores should always be higher than or equal to the minimum valid score of the criterion
    if ((scheme_mix_criterion_params.has_key?(:targeted_score) && (params[:scheme_mix_criterion][:targeted_score].to_i < min_valid_score)) || (scheme_mix_criterion_params.has_key?(:submitted_score) && (params[:scheme_mix_criterion][:submitted_score].to_i < min_valid_score)))
      redirect_to redirect_path, alert: "The targeted and submitted scores of this criterion must be higher than or equal to #{min_valid_score.to_s}."
    else
      @scheme_mix_criterion.update!(scheme_mix_criterion_params)
      redirect_to redirect_path, notice: 'Criterion scores were successfully updated.'
    end
  end

  def assign_certifier
    if params.has_key?(:user_id) && params[:user_id].present?
      @scheme_mix_criterion.certifier = User.find(params[:user_id])
      if params.has_key?(:due_date)
        if params[:due_date] != ''
          @scheme_mix_criterion.due_date = Date.strptime(params[:due_date], t('date.formats.short'))
        else
          @scheme_mix_criterion.due_date = nil
        end
      end
      @scheme_mix_criterion.save!
    end
    redirect_to project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion), notice: 'Criterion certifier responsibility was successfully updated.'
  end

  def list
    total_count = SchemeMixCriterion.joins(:scheme_mix)
                                    .joins(scheme_criterion: [:scheme_category])
                                    .where(scheme_mixes: {certification_path_id: @certification_path.id})
                                    .where('(scheme_categories.code || scheme_criteria.number || \': \' || scheme_criteria.name) like ?', '%' + params[:q] + '%')
                                    .count
    items = SchemeMixCriterion.select('scheme_mixes.id || \';\' || scheme_mix_criteria.id as id_text, scheme_categories.code || scheme_criteria.number || \': \' || scheme_criteria.name as text, scheme_mix_criteria.status')
                              .joins(:scheme_mix)
                              .joins(scheme_criterion: [:scheme_category])
                              .where(scheme_mixes: {certification_path_id: @certification_path.id})
                              .where('(scheme_categories.code || scheme_criteria.number || \': \' || scheme_criteria.name) like ?', '%' + params[:q] + '%')
                              .order('scheme_categories.code', 'scheme_criteria.number')
                              .page(params[:page]).per(25)
    render json: {total_count: total_count, items: items}
  end

  private
  def set_controller_model
    @controller_model = @scheme_mix_criterion
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def scheme_mix_criterion_params
    params.require(:scheme_mix_criterion).permit(:targeted_score, :achieved_score, :submitted_score, :status, :audit_log_user_comment)
  end

end
