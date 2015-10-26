class SchemeMixCriteriaController < AuthenticatedController
  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project
  load_and_authorize_resource :scheme_mix, :through => :certification_path
  load_and_authorize_resource :scheme_mix_criterion, :through => :scheme_mix
  before_action :set_controller_model, except: [:new, :create]

  def show
    @page_title = @scheme_mix_criterion.scheme_criterion.full_name
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
          status = :target_achieved
        else
          status = :target_not_achieved
        end
      elsif @scheme_mix_criterion.verifying_after_appeal?
        if params.has_key?(:achieved)
          status = :target_achieved_after_appeal
        else
          status = :target_not_achieved_after_appeal
        end
      else
        flash[:alert] = 'The criterion status cannot be updated.'
      end

      @scheme_mix_criterion.update!(status: status)
      flash[:notice] = 'Criterion status was sucessfully updated.'
    else
      flash[:alert] = todos.first
    end

    redirect_to project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion)
  end

  def update_scores
    # if not attempting criterion
    if @scheme_mix_criterion.targeted_score == -1
      params[:scheme_mix_criterion][:submitted_score] = -1
    end

    @scheme_mix_criterion.update!(scheme_mix_criterion_params)

    redirect_to project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion), notice: 'Criterion scores were successfully updated.'
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

  private
  def set_controller_model
    @controller_model = @scheme_mix_criterion
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def scheme_mix_criterion_params
    params.require(:scheme_mix_criterion).permit(:targeted_score, :achieved_score, :submitted_score, :status, :audit_log_user_comment)
  end

end
