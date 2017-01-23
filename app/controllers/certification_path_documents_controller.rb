class CertificationPathDocumentsController < BaseDocumentController
  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project
  load_and_authorize_resource :certification_path_document
  skip_authorize_resource :certification_path_document, only: [:new, :create]
  before_action :set_controller_model, except: [:new, :create]

  def create
    respond_to do |format|
      if params.has_key?(:document)
        # Creates the document and its certification_paths_documents
        if can? :create, CertifierCertificationPathDocument.new(certification_path: @certification_path)
          @certification_path_document = CertifierCertificationPathDocument.new(document_params)
        else
          @certification_path_document = CgpCertificationPathDocument.new(document_params)
        end
        # Set the certification path
        @certification_path_document.certification_path = @certification_path

        authorize! :create, @certification_path_document

        # Set the user
        @certification_path_document.user = current_user
        # Set the directory where the file will be stored, this is used by the DocumentUploader class
        @certification_path_document.store_dir = "projects/#{@project.id}/certification_paths/#{@certification_path.id}/documents"
        if @certification_path_document.save
          format.html { redirect_to :back, notice: 'The document was successfully uploaded.' }
          format.json { render json: @certification_path_document }
        else
          format.html { redirect_to :back, alert: @certification_path_document.errors['document_file'].first.to_s }
          format.json { render json: @certification_path_document['document_file'].to_s, status: :unprocessable_entity }
        end
      end
    end
  end

  private
  def set_controller_model
    @controller_model = @certification_path_document
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def document_params
    params.require(:document).permit(:document_file)
  end
end