class SchemeMixCriteriaDocumentsController < AuthenticatedController
  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project
  load_and_authorize_resource :scheme_mix, :through => :certification_path
  load_and_authorize_resource :scheme_mix_criterion, :through => :scheme_mix
  load_and_authorize_resource :scheme_mix_criteria_document, :through => :scheme_mix_criterion
  before_action :set_controller_model, except: [:new_link, :create]

  def new_link
  end

  def create_link
    if params[:scheme_mix_criteria_document].present?
      params[:scheme_mix_criteria_document].each do |smcd_params|
        smcd = SchemeMixCriteriaDocument.new(smcd_params.permit(:scheme_mix_criterion_id))
        smcd.document_id = @scheme_mix_criteria_document.document_id
        smcd.save!
      end
      redirect_to :back, notice: 'The document was successfully linked to the criteria.'
    else
      redirect_to :back, alert: 'No criteria were selected.'
    end
  end

  def edit_status
  end

  def update_status
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

    redirect_to :back, notice: 'The document status was successfully updated.'
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
