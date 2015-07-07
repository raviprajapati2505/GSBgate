class SchemeMixCriteriaDocumentsController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path
  before_action :set_scheme_mix
  before_action :set_scheme_mix_criterion
  before_action :set_scheme_mix_criteria_document
  before_action :set_document
  load_and_authorize_resource

  def edit
    @page_title = (ActionController::Base.helpers.image_tag(Icon.for_filename(@document.document_file.file.filename)) + ' Document ' + @document.document_file.file.filename).html_safe
  end

  def update
    @scheme_mix_criteria_document.update(scheme_mix_criteria_document_params)

    if @scheme_mix_criteria_document.save
      # Create the comment
      if params[:scheme_mix_criteria_document_status]['comment'].present?
        @scheme_mix_criteria_document.scheme_mix_criteria_document_comments.create!(body: params[:scheme_mix_criteria_document_status]['comment'], user: current_user)
      end

      redirect_to :back, notice: 'The document details were successfully updated.'
    else
      redirect_to :back, alert: 'The document details couldn\'t be saved, please try again later.'
    end
  end

  def show
    redirect_to edit_project_certification_path_scheme_mix_scheme_mix_criterion_documentation_path, status: 301
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
    @scheme_mix_criterion = SchemeMixCriterion.find(params[:scheme_mix_criterion_id])
  end

  def set_scheme_mix_criteria_document
    @set_scheme_mix_criteria_document = SchemeMixCriteriaDocument.find(params[:id])
  end

  def set_document
    @document = @set_scheme_mix_criteria_document.document
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def scheme_mix_criteria_document_params
    params.require(:scheme_mix_criteria_document).permit(:status)
  end
end
