class SchemeMixCriteriaController < AuthenticatedController
  include ApplicationHelper
  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project
  load_and_authorize_resource :scheme_mix, :through => :certification_path
  load_and_authorize_resource :scheme_mix_criterion, :through => :scheme_mix
  # don't load the resource for the list action, as it uses a custom query
  skip_load_and_authorize_resource :scheme_mix, only: [:list, :delete_discrepancy_document]
  skip_load_and_authorize_resource :scheme_mix_criterion, only: [:list, :delete_discrepancy_document]
  # skip default update_score authorization, as we have manually created authorization levels per score type
  skip_authorize_resource :scheme_mix_criterion, only: [:update_scores, :update_checklist, :upload_discrepancy_document, :delete_discrepancy_document]
  before_action :set_controller_model, except: [:new, :create, :list, :upload_discrepancy_document, :delete_discrepancy_document]

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

  def apply_pcr
    @data = { }
    
    @data[:pcr] = 'ATTENTION: By clicking this button, you confirm that a PCR is requested for this criterion' if @scheme_mix_criterion.review_count < @certification_path.max_review_count 
    @data[:confirm] = 'You are submitting this criterion without documentation. Are you sure?' if @scheme_mix_criterion.scheme_mix_criteria_documents.count < 1
  end

  def update_status
    todos = @scheme_mix_criterion.todo_before_status_advance

    if todos.blank?
      status = @scheme_mix_criterion.next_status

      if @scheme_mix_criterion.scheme_mix.check_list?
        notice_message = 'The Checklist Status were successfully updated.'
        alert_message = 'The Checklist Status cannot be updated.'
      else
        notice_message = 'Criterion status was sucessfully updated.'
        alert_message = 'The criterion status cannot be updated.'
      end

      if status.present?
        @scheme_mix_criterion.transaction do
          # Update the scheme mix criterion
          @scheme_mix_criterion.status = status
          @scheme_mix_criterion.audit_log_user_comment = params[:scheme_mix_criterion][:audit_log_user_comment]
          @scheme_mix_criterion.audit_log_visibility = params[:scheme_mix_criterion][:audit_log_visibility]
          @scheme_mix_criterion.save!
          @scheme_mix_criterion.update_column(:in_review, false)
        end
        flash[:notice] = notice_message
      else
        flash[:alert] = alert_message
      end
    else
      flash[:alert] = todos.first
    end

    redirect_to project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion)
  end

  def update_scores
    authorize! :update_targeted_score, @scheme_mix_criterion, message: 'Not authorized to update targeted level' if scheme_mix_criterion_params.has_key?(:targeted_score_a)
    authorize! :update_submitted_score, @scheme_mix_criterion, message: 'Not authorized to update submitted level' if scheme_mix_criterion_params.has_key?(:submitted_score_a)
    authorize! :update_achieved_score, @scheme_mix_criterion, message: 'Not authorized to update achieved level' if scheme_mix_criterion_params.has_key?(:achieved_score_a)

    redirect_path = project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion)

    upload_discrepancy_document if params[:scheme_mix_criterion][:epc_matches_energy_suite].to_i == 0
    # The targeted & submitted scores should always be higher than or equal to the minimum valid score of the criterion
    if validate_score(redirect_path)
      # reset incentive_scored for categories E and W for achieved scores <= 0
      reset_incentive_scored
      @scheme_mix_criterion.transaction do
        # Update the scheme mix criterion
        params =  @params ? scheme_mix_criterion_params.merge(scheme_mix_criterion_box_params) : scheme_mix_criterion_params
        @scheme_mix_criterion.update!(params)
      end
      redirect_to redirect_path, notice: 'The Criterion Levels were successfully updated.'
    end
  end

  def update_checklist
    redirect_path = project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion)

    @scheme_mix_criterion.update!(scheme_mix_criterion_box_params)
    redirect_to redirect_path, notice: 'The Checklist Status were successfully updated.'
  end

  def reset_incentive_scored
    if ['E','W'].include?(@scheme_mix_criterion.scheme_criterion.scheme_category.code)
      SchemeCriterion::SCORE_ATTRIBUTES.each_with_index do |scores, index|

        achieved_score_boolean = scheme_mix_criterion_params[SchemeMixCriterion::ACHIEVED_SCORE_ATTRIBUTES[index].to_sym].to_i <= 0

        if (scheme_mix_criterion_params.has_key?(SchemeMixCriterion::ACHIEVED_SCORE_ATTRIBUTES[index].to_sym) && achieved_score_boolean ) && (!scheme_mix_criterion_params.has_key?(SchemeMixCriterion::INCENTIVE_SCORED_ATTRIBUTES[index].to_sym) || (scheme_mix_criterion_params.has_key?(SchemeMixCriterion::INCENTIVE_SCORED_ATTRIBUTES[index].to_sym) && scheme_mix_criterion_params[SchemeMixCriterion::INCENTIVE_SCORED_ATTRIBUTES[index].to_sym].to_i == 1))
          params[:scheme_mix_criterion][SchemeMixCriterion::INCENTIVE_SCORED_ATTRIBUTES[index]] = false
        end
      end
    
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
      flash[:alert] = 'Maximum number of PCR requests reached for this criterion.'
    end
    redirect_to project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion)
  end

  def provide_draft_review_comment
  end

  def add_draft_review_comment
    @scheme_mix_criterion.transaction do
      @scheme_mix_criterion.audit_log_user_comment = params[:scheme_mix_criterion][:pcr_review_draft]
      @scheme_mix_criterion.audit_log_visibility = AuditLogVisibility::INTERNAL
      @scheme_mix_criterion.audit_log_attachment_file = params[:scheme_mix_criterion][:pcr_document]
      @scheme_mix_criterion.pcr_review_draft = params[:scheme_mix_criterion][:pcr_review_draft]
      @scheme_mix_criterion.save!

      # # PCR document
      # if params[:scheme_mix_criterion][:pcr_document].present?
      #   pcr_document = Document.new(document_file: params[:scheme_mix_criterion][:pcr_document], user: current_user, certification_path_id: @certification_path&.id)
      #   pcr_document.scheme_mix_criteria_documents.build(document_type: "pcr_document", scheme_mix_criterion_id: @scheme_mix_criterion&.id)
      #   pcr_document.save!
      # end
    end
    
    flash[:notice] = 'Criterion draft PCR submitted.'
    redirect_to project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion)
  end

  def provide_review_comment
    @scheme_mix_criterion.audit_log_user_comment = @scheme_mix_criterion.pcr_review_draft
  end

  def add_review_comment
    @scheme_mix_criterion.transaction do
      @scheme_mix_criterion.audit_log_user_comment = params[:scheme_mix_criterion][:audit_log_user_comment]
      @scheme_mix_criterion.audit_log_visibility = AuditLogVisibility::PUBLIC
      @scheme_mix_criterion.audit_log_attachment_file = params[:scheme_mix_criterion][:pcr_document]
      @scheme_mix_criterion.in_review = false
      @scheme_mix_criterion.save!

      # # PCR document
      # if params[:scheme_mix_criterion][:pcr_document].present?
      #   pcr_document = Document.new(document_file: params[:scheme_mix_criterion][:pcr_document], user: current_user, certification_path_id: @certification_path&.id)
      #   pcr_document.scheme_mix_criteria_documents.build(document_type: "pcr_document", scheme_mix_criterion_id: @scheme_mix_criterion&.id)
      #   pcr_document.save!
      # end
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
      flash[:notice] = 'You have recently requested an archive for this criterion.'
      render js: "window.location = '/projects/#{@project.id}/certificates/#{@certification_path.id}/schemes/#{@scheme_mix.id}/criteria/#{@scheme_mix_criterion.id}'"
    else
      archive = Archive.new
      archive.user_id = current_user.id
      archive.subject = @scheme_mix_criterion
      archive.status = :not_generated
      params[:all] == "true" ? archive.all_criterion_document = true : archive.criterion_document_ids = params[:documents]
      archive.save!
      flash[:notice] = 'A ZIP archive is being generated. You will be notified by email when the file can be downloaded.'
      render js: "window.location = '/projects/#{@project.id}/certificates/#{@certification_path.id}/schemes/#{@scheme_mix.id}/criteria/#{@scheme_mix_criterion.id}'"
    end
  end

  def upload_discrepancy_document
    return unless params[:scheme_mix_criterion][:epc_discrepancy_documentation].present?
    discrepancy_document = Document.new(document_file: params[:scheme_mix_criterion][:epc_discrepancy_documentation], user: current_user, certification_path_id: @certification_path&.id)
    discrepancy_document.scheme_mix_criteria_documents.build(document_type: "epc_discrepancy_document", scheme_mix_criterion_id: @scheme_mix_criterion&.id)
    if discrepancy_document.save
      flash[:notice] = "Discrepancy Document has successfully uploaded."
    else
      flash[:alert] = "Discrepancy Document is failed upload!"
    end
    # head :ok
  end

  def delete_discrepancy_document
    smcd = SchemeMixCriteriaDocument.find(params[:id])
    discrepancy_document = smcd&.document
    smcd&.destroy if smcd.present?
    discrepancy_document&.destroy if discrepancy_document.present?
    redirect_back(fallback_location: root_path, notice: 'Discrepancy Document has successfully deleted.')
  end

  private
  def set_controller_model
    @controller_model = @scheme_mix_criterion
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def scheme_mix_criterion_params
    permitted_params = [:status, :audit_log_user_comment, :audit_log_visibility, :epc_matches_energy_suite]
    permitted_params += SchemeMixCriterion::TARGETED_SCORE_ATTRIBUTES
    permitted_params += SchemeMixCriterion::ACHIEVED_SCORE_ATTRIBUTES
    permitted_params += SchemeMixCriterion::SUBMITTED_SCORE_ATTRIBUTES
    permitted_params += SchemeMixCriterion::INCENTIVE_SCORED_ATTRIBUTES
    permitted_params += [scheme_mix_criterion_incentives_attributes: [:id, :incentive_scored]]
    permitted_params += [scheme_mix_criterion_epls_attributes: [:id, :epc, :level, :band, :cooling, :lighting, :auxiliaries, :dhw, :others, :generation, :co2_emission]]
    permitted_params += [scheme_mix_criterion_wpls_attributes: [:id, :wpc, :level, :band, :indoor_use, :irrigation, :cooling_tower]]
    params.require(:scheme_mix_criterion).permit(permitted_params)
  end

  def scheme_mix_criterion_box_params
    permitted_params = [scheme_mix_criterion_boxes_attributes: [:id, :is_checked]]
    params.require(:scheme_mix_criterion).permit(permitted_params)
  end

end
