class DocumentsController < BaseDocumentController
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
          scheme_mix_criteria_document.pcr_context = scheme_mix_criteria_document.scheme_mix_criterion.review_count if scheme_mix_criteria_document.scheme_mix_criterion.in_review
        end
        if @document.save
          format.html { redirect_back(fallback_location: root_path, notice: 'The document was successfully uploaded.') }
          format.json { render :json => @document }
        else
          format.html { redirect_back(fallback_location: root_path, alert: @document.errors['document_file'].first.to_s) }
          format.json { render json: @document.errors['document_file'].to_s, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    respond_to do |format|
      # test if document has no approved links before accepting request
      unless Document.where(id: @document.id).joins(:scheme_mix_criteria_documents).exists?(scheme_mix_criteria_documents: {status: SchemeMixCriteriaDocument.statuses[:approved]})
        directories = @controller_model.document_file.store_dir.split('/')
        directories.delete_at(0) # delete '..'
        directories.delete_at(0) # delete 'private' subdirectory
        directory = directories.join('/')
        filepath = Rails.root.to_s + '/private/' + directory + '/' + @controller_model.name
        # delete physical file
        begin
          File.delete(filepath)
        rescue Errno::ENOENT
        end
        # delete empty directories
        begin
          until directories.empty?
            directory = directories.join('/')
            Dir.delete(Rails.root.to_s + '/private/' + directory)
            directories.pop
          end
        rescue SystemCallError
        end
        # delete database record
        @controller_model.destroy
        format.html { redirect_back(fallback_location: root_path, notice: 'The document was successfully deleted.') }
      else
        format.html { redirect_back(fallback_location: root_path, alert: 'The document is already approved for some criteria and can not be deleted anymore.') }
      end
    end
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
