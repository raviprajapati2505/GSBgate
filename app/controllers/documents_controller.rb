class DocumentsController < AuthenticatedController
  before_action :set_project, only: [:create]
  before_action :set_certification_path, only: [:create]
  before_action :set_document, only: [:show]
  load_and_authorize_resource skip_load_resource # todo: remove skip_load_resource

  def create
    respond_to do |format|
      if params.has_key?(:document)
        # Create the document
        @document = Document.new(document_file: params[:document]['document_file'], user: current_user)

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
  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_certification_path
    @certification_path = CertificationPath.find(params[:certification_path_id])
  end

  def set_document
    @document = Document.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def document_params
    params.require(:document).permit(:document_file)
  end
end
