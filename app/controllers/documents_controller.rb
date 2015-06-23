class DocumentsController < AuthenticatedController
  before_action :set_document, only: [:download]
  load_and_authorize_resource

  def create
    respond_to do |format|
      if params.has_key?(:document)
        @document = Document.new(document_file: params[:document]['document_file'], user: current_user)

        if @document.save
          SchemeMixCriteriaDocument.create!(scheme_mix_criterion_id: params[:document]['scheme_mix_criterion'], document: @document)

          format.html { redirect_to :back, notice: 'The document was successfully uploaded.' }
          format.json { render :json => @document }
        else
          format.html { redirect_to :back, alert: @document.errors['document_file'].first.to_s }
          format.json { render json: @document.errors['document_file'].to_s, status: :unprocessable_entity }
        end
      end
    end
  end

  def download
    send_file @document.document_file.file.path
  end

  private
  def set_document
    @document = Document.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def document_params
    params.require(:document).permit(:document_file)
  end
end
