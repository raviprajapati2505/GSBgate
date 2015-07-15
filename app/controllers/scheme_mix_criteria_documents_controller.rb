class SchemeMixCriteriaDocumentsController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path
  before_action :set_scheme_mix
  before_action :set_scheme_mix_criterion
  before_action :set_scheme_mix_criteria_document, only: [:edit, :update, :show, :destroy]
  before_action :set_document, only: [:edit, :update, :show, :destroy]
  load_and_authorize_resource

  def create
    if SchemeMixCriteriaDocument.exists?(scheme_mix_criteria_document_params)
      redirect_to :back, alert: 'This criterion is already linked to the document.'
    else
      scheme_mix_criteria_document = SchemeMixCriteriaDocument.new(scheme_mix_criteria_document_params)

      if scheme_mix_criteria_document.save!
        redirect_to :back, notice: 'The criterion was successfully linked to this document.'
      else
        redirect_to :back, alert: 'An error occurred when linking the criterion to this document, please try again later.'
      end
    end
  end

  def edit
    @page_title = (ActionController::Base.helpers.image_tag(Icon.for_filename(@document.document_file.file.filename)) + ' Document ' + @document.document_file.file.filename).html_safe
  end

  def update
    # Load all scheme_mix_criteria_documents that need to be updated
    scheme_mix_criteria_documents = []
    scheme_mix_criteria_documents << @scheme_mix_criteria_document

    if params[:scheme_mix_criteria].present?
      params[:scheme_mix_criteria].each do |scheme_mix_criterion_id|
        unless scheme_mix_criterion_id == @scheme_mix_criteria_document.id
          scheme_mix_criteria_documents << SchemeMixCriteriaDocument.find_by(scheme_mix_criterion_id: scheme_mix_criterion_id, document_id: @scheme_mix_criteria_document.document_id)
        end
      end
    end

    # Loop all scheme_mix_criteria_documents
    scheme_mix_criteria_documents.each do |scheme_mix_criteria_document|
      # Update the model data
      scheme_mix_criteria_document.update(scheme_mix_criteria_document_params)

      # Save the link scheme_mix_criteria_document
      if scheme_mix_criteria_document.save
        # Create the comment
        if params[:scheme_mix_criteria_document_comment]['body'].present?
          scheme_mix_criteria_document.scheme_mix_criteria_document_comments.create!(body: params[:scheme_mix_criteria_document_comment]['body'], user: current_user)
        end

        # Create a notification for the document uploader
        notify(body: 'The status of your document %s in %s was changed to %s.',
               body_params: [@document.document_file.file.filename, scheme_mix_criteria_document.scheme_mix_criterion.name, scheme_mix_criteria_document.status.humanize],
               uri: edit_project_certification_path_scheme_mix_scheme_mix_criterion_scheme_mix_criteria_document_path(@project, @certification_path, scheme_mix_criteria_document.scheme_mix_criterion.scheme_mix, scheme_mix_criteria_document.scheme_mix_criterion, scheme_mix_criteria_document),
               user: @document.user,
               project: @project)
      end
    end

    redirect_to :back, notice: 'The document details were successfully updated.'
  end

  def show
    redirect_to edit_project_certification_path_scheme_mix_scheme_mix_criterion_scheme_mix_criteria_document_path, status: 301
  end

  def destroy
    @scheme_mix_criteria_document.destroy!
    redirect_to :back, notice: 'The criterion link was successfully removed from the document.'
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
    @scheme_mix_criteria_document = SchemeMixCriteriaDocument.find(params[:id])
  end

  def set_document
    @document = @scheme_mix_criteria_document.document
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def scheme_mix_criteria_document_params
    params.require(:scheme_mix_criteria_document).permit(:status, :scheme_mix_criterion_id, :document_id)
  end
end
