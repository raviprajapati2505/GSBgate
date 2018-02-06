class SchemeMixCriteriaController < AuthenticatedController
  include ApplicationHelper
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
        @page_title = ERB::Util.html_escape(@scheme_mix_criterion.scheme_criterion.full_name.to_s)
        @prev_smc = @scheme_mix_criterion.previous_scheme_mix_criterion
        @next_smc = @scheme_mix_criterion.next_scheme_mix_criterion
        # hide real criterion status in some cases
        @scheme_mix_criterion.visible_status
      }
      format.json { render json: {id: @scheme_mix_criterion.scheme_mix.id.to_s + ';' + @scheme_mix_criterion.id.to_s, name: @scheme_mix_criterion.full_name}, status: :ok }
    end
  end

  def edit_status
  end

  def update_status
    todos = @scheme_mix_criterion.todo_before_status_advance

    if todos.blank?
      status = @scheme_mix_criterion.next_status

      if status.present?
        @scheme_mix_criterion.transaction do
          # Update the scheme mix criterion
          @scheme_mix_criterion.status = status
          @scheme_mix_criterion.audit_log_user_comment = params[:scheme_mix_criterion][:audit_log_user_comment]
          @scheme_mix_criterion.audit_log_visibility = params[:scheme_mix_criterion][:audit_log_visibility]
          @scheme_mix_criterion.save!
          @scheme_mix_criterion.update_column(:in_review, false)
        end
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
    authorize! :update_targeted_score, @scheme_mix_criterion, message: 'Not authorized to update targeted score' if scheme_mix_criterion_params.has_key?(:targeted_score_a)
    authorize! :update_submitted_score, @scheme_mix_criterion, message: 'Not authorized to update submitted score' if scheme_mix_criterion_params.has_key?(:submitted_score_a)
    authorize! :update_achieved_score, @scheme_mix_criterion, message: 'Not authorized to update achieved score' if scheme_mix_criterion_params.has_key?(:achieved_score_a)

    redirect_path = project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion)

    # If not attempting this criterion, set submitted score to minimum valid score
    SchemeMixCriterion::TARGETED_SCORE_ATTRIBUTES.each_with_index do |targeted_score, index|
      if scheme_mix_criterion_params.has_key?(targeted_score.to_sym) && (params[:scheme_mix_criterion][targeted_score.to_sym].to_i == @scheme_mix_criterion.scheme_criterion.read_attribute(SchemeCriterion::MIN_VALID_SCORE_ATTRIBUTES[index].to_sym))
        params[:scheme_mix_criterion][SchemeMixCriterion::SUBMITTED_SCORE_ATTRIBUTES[index].to_sym] = params[:scheme_mix_criterion][targeted_score.to_sym]
      end
    end

    # The targeted & submitted scores should always be higher than or equal to the minimum valid score of the criterion
    if validate_score(redirect_path)
      @scheme_mix_criterion.transaction do
        # Update the scheme mix criterion
        @scheme_mix_criterion.update!(scheme_mix_criterion_params)
      end
      redirect_to redirect_path, notice: 'Criterion scores were successfully updated.'
    end
  end

  def validate_score(redirect_path)
    SchemeMixCriterion::TARGETED_SCORE_ATTRIBUTES.each_with_index do |targeted_score, index|
      min_valid_score = @scheme_mix_criterion.scheme_criterion.read_attribute(SchemeCriterion::MIN_VALID_SCORE_ATTRIBUTES[index].to_sym)
      if ((scheme_mix_criterion_params.has_key?(targeted_score.to_sym) && (params[:scheme_mix_criterion][targeted_score.to_sym].to_i < min_valid_score)) || (scheme_mix_criterion_params.has_key?(SchemeMixCriterion::SUBMITTED_SCORE_ATTRIBUTES[index].to_sym) && (params[:scheme_mix_criterion][SchemeMixCriterion::SUBMITTED_SCORE_ATTRIBUTES[index].to_sym].to_i < min_valid_score)))
        redirect_to redirect_path, alert: "The targeted and submitted scores of this criterion must be higher than or equals to #{min_valid_score.to_s}."
      end
    end
    true
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

  def request_review
    if @scheme_mix_criterion.review_count < @certification_path.max_review_count
      @scheme_mix_criterion.review_count += 1
      @scheme_mix_criterion.in_review = true
      @scheme_mix_criterion.save!

      # Clear any previous PCR data
      @scheme_mix_criterion.update_column(:certifier_id, nil)
      @scheme_mix_criterion.update_column(:due_date, nil)
      @scheme_mix_criterion.update_column(:pcr_review_draft, nil)

      flash[:notice] = 'Criterion is sent for review.'
    else
      flash[:alert] = 'Maximum number of PCR review requests reached for this criterion.'
    end
    redirect_to project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion)
  end

  def provide_draft_review_comment
  end

  def add_draft_review_comment
    @scheme_mix_criterion.transaction do
      @scheme_mix_criterion.audit_log_user_comment = params[:scheme_mix_criterion][:pcr_review_draft]
      @scheme_mix_criterion.audit_log_visibility = AuditLogVisibility::INTERNAL
      @scheme_mix_criterion.pcr_review_draft = params[:scheme_mix_criterion][:pcr_review_draft]
      @scheme_mix_criterion.save!
    end
    flash[:notice] = 'Criterion draft PCR review submitted.'
    redirect_to project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion)
  end

  def provide_review_comment
    @scheme_mix_criterion.audit_log_user_comment = @scheme_mix_criterion.pcr_review_draft
  end

  def add_review_comment
    @scheme_mix_criterion.transaction do
      @scheme_mix_criterion.audit_log_user_comment = params[:scheme_mix_criterion][:audit_log_user_comment]
      @scheme_mix_criterion.audit_log_visibility = AuditLogVisibility::PUBLIC
      @scheme_mix_criterion.in_review = false
      @scheme_mix_criterion.save!
    end
    flash[:notice] = 'Criterion review submitted.'
    redirect_to project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion)
  end

  def screen
    @scheme_mix_criterion.screened = true
    @scheme_mix_criterion.save!
    flash[:notice] = 'Criterion was marked as screened.'
    redirect_to project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion)
  end

  def download_archive
    last_archive = Archive.order(created_at: :desc).find_by(user_id: current_user.id, subject: @scheme_mix_criterion)

    if last_archive.present? && (last_archive.created_at > (Time.now - 3.minutes))
      redirect_to project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion), alert: 'You have recently requested an archive for this criterion.'
    else
      archive = Archive.new
      archive.user_id = current_user.id
      archive.subject = @scheme_mix_criterion
      archive.save!
      GenerateArchiveJob.perform_later(archive)
      redirect_to project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion), notice: 'A ZIP archive is being generated. You will be notified by email when the file can be downloaded.'
    end
  end

  private
  def set_controller_model
    @controller_model = @scheme_mix_criterion
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def scheme_mix_criterion_params
    permitted_params = [:status, :audit_log_user_comment, :audit_log_visibility]
    permitted_params += SchemeMixCriterion::TARGETED_SCORE_ATTRIBUTES
    permitted_params += SchemeMixCriterion::ACHIEVED_SCORE_ATTRIBUTES
    permitted_params += SchemeMixCriterion::SUBMITTED_SCORE_ATTRIBUTES
    permitted_params += SchemeMixCriterion::INCENTIVE_SCORED_ATTRIBUTES
    params.require(:scheme_mix_criterion).permit(permitted_params)
  end

end
