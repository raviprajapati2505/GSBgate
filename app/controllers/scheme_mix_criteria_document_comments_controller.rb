class SchemeMixCriteriaDocumentCommentsController < AuthenticatedController
  before_action :set_scheme_mix_criteria_document
  load_and_authorize_resource

  def create
    comment = SchemeMixCriteriaDocumentComment.new(scheme_mix_criteria_document_comment_params)
    comment.user = current_user
    comment.scheme_mix_criteria_document = @scheme_mix_criteria_document

    if comment.save
      redirect_to :back, notice: 'The comment was successfully added.'
    else
      redirect_to :back, alert: 'The comment couldn\'t be saved, please try again later.'
    end
  end

  private

  def set_scheme_mix_criteria_document
    @scheme_mix_criteria_document = SchemeMixCriteriaDocument.find(params[:scheme_mix_criteria_document_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def scheme_mix_criteria_document_comment_params
    params.require(:scheme_mix_criteria_document_comment).permit(:body)
  end
end
