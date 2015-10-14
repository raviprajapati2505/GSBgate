class DocumentsController < AuthenticatedController
  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project
  load_and_authorize_resource :document
  # cancan authorization will fail during create, as we don't have a link with the rest of our models yet
  #  todo: have our form pass correctly formatted params, so cancan load resource can create the necessary child models, so we cna pass authorization
  skip_authorize_resource :document, :only => :create
  before_action :set_controller_model

  def create
    respond_to do |format|
      if params.has_key?(:document)
        # Create the document
        @document = Document.new(document_file: params[:document]['document_file'], user: current_user)

        # Set the directory where the file will be stored, this is used by the DocumentUploader class
        @document.store_dir = "projects/#{@project.id}/certification_paths/#{@certification_path.id}/documents"

        if @document.save
          # Create links with the scheme mix criteria
          params[:document]['scheme_mix_criteria'].each do |scheme_mix_criterion_id|
            @document.scheme_mix_criteria_documents.create!(scheme_mix_criterion_id: scheme_mix_criterion_id, audit_log_user_comment: params[:scheme_mix_criteria_document]['audit_log_user_comment'])
          end

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

  def create_params
    # TODO: handle custom params when creating a document
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def document_params
    params.require(:document).permit(:document_file)
  end
end
