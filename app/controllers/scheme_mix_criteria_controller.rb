class SchemeMixCriteriaController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path
  before_action :set_scheme_mix
  before_action :set_scheme_mix_criterion
  load_and_authorize_resource

  def edit
    @page_title = @scheme_mix_criterion.scheme_criterion.code + ': ' + @scheme_mix_criterion.scheme_criterion.criterion.name
  end

  def update
    respond_to do |format|
      # if not attempting criterion
      if @scheme_mix_criterion.targeted_score == -1 && params[:scheme_mix_criterion][:status] == :complete.to_s
        params[:scheme_mix_criterion][:submitted_score] = -1
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

        format.html { redirect_to edit_project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion), notice: 'Criterion was successfully updated.' }
        format.json { render json: @scheme_mix_criterion, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @scheme_mix_criterion.errors, status: :unprocessable_entity }
      end
    end
  end

  def assign_certifier
    if params.has_key?(:user_id)
      @scheme_mix_criterion.certifier = User.find(params[:user_id])
      @scheme_mix_criterion.due_date = Date.strptime(params[:due_date], t('date.formats.short')) if (params.has_key?(:due_date) && params[:due_date] != '')
      @scheme_mix_criterion.save!
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
