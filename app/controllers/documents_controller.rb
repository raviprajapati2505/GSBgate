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
            if scheme_mix_criteria_document = @document.scheme_mix_criteria_documents.create!(scheme_mix_criterion_id: scheme_mix_criterion_id)
              # Create the comment
              if params[:document]['comment'].present?
                scheme_mix_criteria_document.scheme_mix_criteria_document_comments.create!(body: params[:document]['comment'], user: current_user)
              end

              # Notify the project managers of the new document
              @project.managers.each do |project_manager|
                notify(body: 'A new document %s was uploaded in %s.',
                       body_params: [@document.document_file.file.filename, scheme_mix_criteria_document.scheme_mix_criterion.name],
                       uri: project_certification_path_scheme_mix_scheme_mix_criterion_scheme_mix_criteria_document_path(@project, @certification_path, scheme_mix_criteria_document.scheme_mix_criterion.scheme_mix, scheme_mix_criteria_document.scheme_mix_criterion, scheme_mix_criteria_document),
                       user: project_manager,
                       project: @project)
              end
            end
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
    send_file @document.document_file.file.path
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
