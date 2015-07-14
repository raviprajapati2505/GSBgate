class SchemeMixCriteriaController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path
  before_action :set_scheme_mix
  before_action :set_scheme_mix_criterion
  load_and_authorize_resource

  def edit
    @page_title = @scheme_mix_criterion.name
  end

  def show
    redirect_to edit_project_certification_path_scheme_mix_scheme_mix_criterion_path, status: 301
  end

  def update
      if scheme_mix_criterion_params[:status] == :approved.to_s || scheme_mix_criterion_params[:status] == :resubmit.to_s
        # if achieved score is not yet provided only the status can only be 'in progress' or 'complete'
        if @scheme_mix_criterion.achieved_score.nil?
          flash[:alert] = 'You first have to provide achieved score'
          render :edit
          return
        end
      elsif scheme_mix_criterion_params[:status] == :complete.to_s
        # TODO All linked documents must be 'approved' (according the assessor manual, but what about rejected and superseded documents) ?
        # and all requirements must be marked as 'provided' or 'not required'
        @scheme_mix_criterion.requirement_data.each do |requirement_datum|
          if requirement_datum.status == :required.to_s
            flash[:alert] = 'All requirements should first be approved or set to \'not required\''
            render :edit
            return
          end
        end

        # if not attempting criterion
        if @scheme_mix_criterion.targeted_score == -1
          params[:scheme_mix_criterion][:submitted_score] = -1
        end
      end

      old_status = @scheme_mix_criterion[:status]
      if @scheme_mix_criterion.update(scheme_mix_criterion_params)
        # Save justification comments
        if params[:scheme_mix_criterion].has_key?(:scheme_mix_criterion_logs)
          @scheme_mix_criterion.scheme_mix_criterion_logs.create!(comment: params[:scheme_mix_criterion][:scheme_mix_criterion_logs][:comment], user: current_user, old_status: old_status, new_status: @scheme_mix_criterion[:status] )
        end
        # Save the documents
        if params.has_key?(:documents)
          params[:documents]['document_file'].each do |document_file|
            @scheme_mix_criterion.documents.create!(document_file: document_file, user: current_user)
          end
        end

        redirect_to edit_project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion), notice: 'Criterion was successfully updated.'
      else
        render :edit
      end
  end

  def assign_certifier
    if params.has_key?(:user_id)
      old_user = @scheme_mix_criterion.certifier
      @scheme_mix_criterion.certifier = User.find(params[:user_id])
      @scheme_mix_criterion.due_date = Date.strptime(params[:due_date], t('date.formats.short')) if (params.has_key?(:due_date) && params[:due_date] != '')
      SchemeMixCriterion.transaction do
        if !@scheme_mix_criterion.certifier.nil? && (old_user != @scheme_mix_criterion.certifier)
          # Notify certifier
          if @scheme_mix_criterion.due_date.nil?
            Notification.create(body: 'Criterion "' + @scheme_mix_criterion.name  + '" is assigned to you for review.', uri: project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion), user: @scheme_mix_criterion.certifier, project: @project)
          else
            Notification.create(body: 'Criterion "' + @scheme_mix_criterion.name  + '" is assigned to you for review. The due date is ' + (l @scheme_mix_criterion.due_date, format: :short) + '.', uri: project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion), user: @scheme_mix_criterion.certifier, project: @project)
          end
        end
        @scheme_mix_criterion.save!
      end
      redirect_to edit_project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion), notice: 'Criterion was successfully updated.'
    end
  end

  private
  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_certification_path
    @certification_path = CertificationPath.find(params[:certification_path_id])
  end

  def set_scheme_mix
    @scheme_mix = SchemeMix.find(params[:scheme_mix_id])
  end

  def set_scheme_mix_criterion
    @scheme_mix_criterion = SchemeMixCriterion.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def scheme_mix_criterion_params
    params.require(:scheme_mix_criterion).permit(:targeted_score, :achieved_score, :submitted_score, :status)
  end

end
