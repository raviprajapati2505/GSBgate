class SchemeMixCriteriaController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path
  before_action :set_scheme_mix
  before_action :set_scheme_mix_criterion
  load_and_authorize_resource

  def edit
    @page_title = @scheme_mix_criterion.scheme_criterion.code + ' ' + @scheme_mix_criterion.scheme_criterion.criterion.name
  end

  def update
    if @scheme_mix_criterion.update(scheme_mix_criterion_params)
      render json: @scheme_mix_criterion, status: :ok
    else
      render json: @scheme_mix_criterion.errors, status: :unprocessable_entity
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
    params.require(:scheme_mix_criterion).permit(:targeted_score, :achieved_score)
  end

end
