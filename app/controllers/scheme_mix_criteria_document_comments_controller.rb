class SchemeMixCriteriaDocumentCommentsController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path
  before_action :set_scheme_mix
  before_action :set_scheme_mix_criterion
  before_action :set_scheme_mix_criteria_document
  load_and_authorize_resource

  def create
    comment = SchemeMixCriteriaDocumentComment.new(scheme_mix_criteria_document_comment_params)
    comment.user = current_user
    comment.scheme_mix_criteria_document = @scheme_mix_criteria_document

    if comment.save
      # Notify the document owner
      notify(body: 'A comment was added to your document %s.',
             body_params: [@scheme_mix_criteria_document.document.document_file.file.filename],
             uri: project_certification_path_scheme_mix_scheme_mix_criterion_scheme_mix_criteria_document_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion, @scheme_mix_criteria_document) + '#comment-' + comment.id.to_s,
             user: @scheme_mix_criteria_document.document.user,
             project: @project)

      # Notify all users that have added comments to the document
      @scheme_mix_criteria_document.commenters.uniq.each do |commenter|
        if commenter.id != @scheme_mix_criteria_document.document.user.id
          notify(body: 'A comment was added to document %s.',
                 body_params: [@scheme_mix_criteria_document.document.document_file.file.filename],
                 uri: project_certification_path_scheme_mix_scheme_mix_criterion_scheme_mix_criteria_document_path(@project, @certification_path, @scheme_mix, @scheme_mix_criterion, @scheme_mix_criteria_document) + '#comment-' + comment.id.to_s,
                 user: commenter,
                 project: @project)
        end
      end

      redirect_to :back, notice: 'The comment was successfully added.'
    else
      redirect_to :back, alert: 'The comment couldn\'t be saved, please try again later.'
    end
  end

  private
  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_certification_path
    @certification_path = CertificationPath.find(params[:certification_path_id])
  end

  def set_scheme_mix
    @scheme_mix = SchemeMix.find(params[:scheme_mix_id])
  end

  def set_scheme_mix_criterion
    @scheme_mix_criterion = SchemeMixCriterion.find(params[:scheme_mix_criterion_id])
  end

  def set_scheme_mix_criteria_document
    @scheme_mix_criteria_document = SchemeMixCriteriaDocument.find(params[:scheme_mix_criteria_document_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def scheme_mix_criteria_document_comment_params
    params.require(:scheme_mix_criteria_document_comment).permit(:body)
  end
end
