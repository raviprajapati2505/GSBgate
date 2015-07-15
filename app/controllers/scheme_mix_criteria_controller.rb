class SchemeMixCriteriaController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path
  before_action :set_scheme_mix
  before_action :set_scheme_mix_criterion
  load_and_authorize_resource

  def show
    @page_title = @scheme_mix_criterion.name
  end

  def update
      if scheme_mix_criterion_params[:status] == :approved.to_s || scheme_mix_criterion_params[:status] == :resubmit.to_s
        # if achieved score is not yet provided only the status can only be 'in progress' or 'complete'
        if @scheme_mix_criterion.achieved_score.nil?
          flash[:alert] = 'You first have to provide achieved score'
          render :show
          return
        end
      elsif scheme_mix_criterion_params[:status] == :complete.to_s
        # TODO All linked documents must be 'approved' (according the assessor manual, but what about rejected and superseded documents) ?
        # and all requirements must be marked as 'provided' or 'not required'
        @scheme_mix_criterion.requirement_data.each do |requirement_datum|
          if requirement_datum.status == :required.to_s
            flash[:alert] = 'All requirements should first be approved or set to \'not required\''
            render :show
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

        redirect_to project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion), notice: 'Criterion was successfully updated.'
      else
        render :show
      end
  end

  def assign_certifier
    if params.has_key?(:user_id)
      @scheme_mix_criterion.certifier = User.find(params[:user_id])
      if params.has_key?(:due_date)
        if params[:due_date] != ''
          @scheme_mix_criterion.due_date = Date.strptime(params[:due_date], t('date.formats.short'))
        else
          @scheme_mix_criterion.due_date = nil
        end
      end
      SchemeMixCriterion.transaction do
        if @scheme_mix_criterion.certifier_id_changed?
          # Notify certifier
          if @scheme_mix_criterion.due_date.nil?
            notify(body: 'Criterion %s is assigned to you for review.',
                   body_params: [@scheme_mix_criterion.name],
                   uri: project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion),
                   user: @scheme_mix_criterion.certifier,
                   project: @project)
          else
            notify(body: 'Criterion %s is assigned to you for review. The due date is %s.',
                   body_params: [@scheme_mix_criterion.name, l(@scheme_mix_criterion.due_date, format: :short)],
                   uri: project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion),
                   user: @scheme_mix_criterion.certifier,
                   project: @project)
          end
        else
          if @scheme_mix_criterion.due_date_changed?
            # Notify certifier
            if @scheme_mix_criterion.due_date.nil?
              notify(body: 'Due date for criterion %s is removed.',
                     body_params: [@scheme_mix_criterion.name],
                     uri: project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion),
                     user: @scheme_mix_criterion.certifier,
                     project: @project)
            else
              notify(body: 'Due date for criterion %s is changed to %s.',
                     body_params: [@scheme_mix_criterion.name, l(@scheme_mix_criterion.due_date, format: :short)],
                     uri: project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion),
                     user: @scheme_mix_criterion.certifier,
                     project: @project)
            end

          end
        end
        @scheme_mix_criterion.save!
      end
      redirect_to project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion), notice: 'Criterion was successfully updated.'
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
