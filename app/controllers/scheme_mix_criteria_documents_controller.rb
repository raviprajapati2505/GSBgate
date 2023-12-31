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

      redirect_back(fallback_location: root_path, notice: 'The document was successfully linked to the criteria.')
    else
      redirect_back(fallback_location: root_path, alert: 'No criteria were selected.')
    end
  end

  def unlink
  end

  def destroy_link
    if params[:scheme_mix_criteria_document].present?
      # delete audit logs
      AuditLog.where(auditable_type: 'SchemeMixCriteriaDocument', auditable_id: @scheme_mix_criteria_document.id).delete_all
      SchemeMixCriteriaDocument.where(document_id: @scheme_mix_criteria_document.document_id)
          .where.not(scheme_mix_criterion_id: params[:scheme_mix_criteria_document].map {|smcd| smcd[:scheme_mix_criterion_id].to_i})
          .delete_all
      redirect_back(fallback_location: root_path, notice:'The document was successfully unlinked from the criteria.')
    else
      redirect_back(fallback_location: root_path, alert: 'No criteria were selected.')
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
    # update the approved_date params if document approved
    if params[:scheme_mix_criteria_document][:approved_date] == ""
      params[:scheme_mix_criteria_document][:approved_date] = params[:scheme_mix_criteria_document][:status] == "approved" ? Time.now : nil
    else
      params[:scheme_mix_criteria_document][:approved_date] = nil if params[:scheme_mix_criteria_document][:status] != "approved"
    end    
      # Update the model data
      scheme_mix_criteria_document.update(scheme_mix_criteria_document_params)
      
    end

    redirect_back(fallback_location: root_path, notice: 'The document status was successfully updated.')
  end

  private
  def set_controller_model
    @controller_model = @scheme_mix_criteria_document
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def scheme_mix_criteria_document_params
    params.require(:scheme_mix_criteria_document).permit(:status,:approved_date,:scheme_mix_criterion_id, :document_id, :audit_log_user_comment)
  end
end
