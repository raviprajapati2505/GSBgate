class SchemeMixCriteriaDocumentsController < AuthenticatedController
  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project
  load_and_authorize_resource :scheme_mix, :through => :certification_path
  load_and_authorize_resource :scheme_mix_criterion, :through => :scheme_mix
  load_and_authorize_resource :scheme_mix_criteria_document, :through => :scheme_mix_criterion
  before_action :set_controller_model

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

  def show
    @page_title = (ActionController::Base.helpers.image_tag(Icon.for_filename(@scheme_mix_criteria_document.document.name)) + ' ' + @scheme_mix_criteria_document.document.name).html_safe
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
    end

    redirect_to :back, notice: 'The document details were successfully updated.'
  end

  private
  def set_controller_model
    @controller_model = @scheme_mix_criteria_document
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def scheme_mix_criteria_document_params
    params.require(:scheme_mix_criteria_document).permit(:status, :scheme_mix_criterion_id, :document_id, :audit_log_user_comment)
  end
end
