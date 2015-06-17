class DocumentsController < AuthenticatedController
  load_and_authorize_resource

  def create
    if params.has_key?(:document)
      params[:document]['document_file'].each do |document_file|
        document = Document.create!(document_file: document_file, user: current_user)
        SchemeMixCriteriaDocument.create!(scheme_mix_criterion_id: params[:document]['scheme_mix_criterion'], document: document)
      end

      redirect_to :back, notice: 'The documents were successfully created.'
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def document_params
    params.require(:document).permit(:document_file)
  end
end
