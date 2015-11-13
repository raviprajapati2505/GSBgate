class DocumentsController < AuthenticatedController
  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project
  load_and_authorize_resource :document
  before_action :set_controller_model, except: [:new, :create]

  def create
    respond_to do |format|
      if params.has_key?(:document)
        # Creates the document and its scheme_mix_criteria_documents
        @document = Document.new(document_params)
        # Set the user
        @document.user = current_user
        # Set the directory where the file will be stored, this is used by the DocumentUploader class
        @document.store_dir = "projects/#{@project.id}/certification_paths/#{@certification_path.id}/documents"
        # Add the user comment to all scheme_mix_criteria_documents
        @document.scheme_mix_criteria_documents.each do |scheme_mix_criteria_document|
          scheme_mix_criteria_document.audit_log_user_comment = params[:scheme_mix_criteria_document]['audit_log_user_comment']
        end
        if @document.save
          format.html { redirect_to :back, notice: 'The document was successfully uploaded.' }
          format.json { render :json => @document }
        else
          format.html { redirect_to :back, alert: @document.errors['document_file'].first.to_s }
          format.json { render json: @document.errors['document_file'].to_s, status: :unprocessable_entity }
        end
      end
    end
  end

  def show
    send_file @document.path
  end

  private
  def set_controller_model
    @controller_model = @document
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def document_params
    params.require(:document).permit(:document_file, scheme_mix_criteria_documents_attributes: [:scheme_mix_criterion_id, :document_id, :status])
  end
end
