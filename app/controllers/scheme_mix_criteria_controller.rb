class SchemeMixCriteriaController < AuthenticatedController
  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project
  load_and_authorize_resource :scheme_mix, :through => :certification_path
  load_and_authorize_resource :scheme_mix_criterion, :through => :scheme_mix
  before_action :set_controller_model

  def show
    @page_title = @scheme_mix_criterion.scheme_criterion.full_name
  end

  def update
      if scheme_mix_criterion_params[:status] == :approved.to_s || scheme_mix_criterion_params[:status] == :resubmit.to_s
        # if achieved score is not yet provided only the status can only be 'in progress' or 'complete'
        if @scheme_mix_criterion.targeted_score.nil? && @scheme_mix_criterion.achieved_score.nil?
          flash.now[:alert] = 'Please first provide the achieved score.'
          render :show
          return
        end
      elsif scheme_mix_criterion_params[:status] == :complete.to_s
        # all requirements must be marked as 'provided' or 'not required'
        @scheme_mix_criterion.requirement_data.each do |requirement_datum|
          if requirement_datum.status == :required.to_s
            flash.now[:alert] = 'All requirements should first be approved or set to \'not required\'.'
            render :show
            return
          end
        end
        # no linked document can be 'awaiting approval'
        if @scheme_mix_criterion.has_documents_awaiting_approval?
          flash.now[:alert] = 'No document can be \'awaiting approval\'.'
          render :show
          return
        end
      end

      # if not attempting criterion
      if @scheme_mix_criterion.targeted_score == -1
        params[:scheme_mix_criterion][:submitted_score] = -1
      end

      if @scheme_mix_criterion.update(scheme_mix_criterion_params)
        # Save the documents
        if params.has_key?(:documents)
          params[:documents]['document_file'].each do |document_file|
            @scheme_mix_criterion.documents.create!(document_file: document_file, user: current_user)
          end
        end

        redirect_to project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion), notice: 'Criterion was successfully updated.'
      else
        render :show
      end
  end

  def assign_certifier
    if params.has_key?(:user_id) and params[:user_id].present?
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
    redirect_to project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion), notice: 'Criterion was successfully updated.'
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
