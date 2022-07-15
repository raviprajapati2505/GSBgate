module Offline
  class ProjectsController < AuthenticatedController
    include ActionView::Helpers::TranslationHelper
    load_and_authorize_resource param_method: :project_params
    before_action :set_controller_model, only: [:edit, :update, :show, :destroy]
    before_action :set_project, only: [:edit, :update, :show, :destroy, :upload_documents]
    before_action :set_project_document, only: [:download_document, :destroy_document]

    def index
      @page_title = t('offline.projects.index.title_html')
      @datatable = Effective::Datatables::OfflineProjects.new
    end

    def new
      @page_title = t('offline.projects.index.btn_new_project')
      @project = Offline::Project.new
    end

    def create
      @project = Offline::Project.new(project_params)
      if @project.save
        redirect_to @project, notice: 'Project was successfully created.'
      else
        render :new
      end
    end

    def edit;
      @page_title = t('offline.projects.index.btn_edit_project')
    end

    def show 
      @page_title = ERB::Util.html_escape(@project.name.to_s)
    end

    def update
      respond_to do |format|
        if @project.update(project_params)
          format.html { redirect_to offline_projects_path, notice: 'Project was successfully updated.' }
          format.json { render :show, status: :ok, location: @project }
        else
          format.html { render :edit }
          format.json { render json: @project.errors, status: :unprocessable_entity }
        end
      end
    end

    def confirm_destroy
      @page_title = ERB::Util.html_escape(@project.name.to_s)
    end

    def destroy
      if @project.destroy
        redirect_to offline_projects_path, notice: 'The project was successfully removed.'
      else
        redirect_to offline_projects_path, alert: 'An error occurred when trying to remove the project. Please try again later.'
      end
    end

    def upload_documents
      respond_to do |format|
        if params.has_key?(:offline_project)
          @project_document = @project.offline_project_documents.new(params.require(:offline_project).permit(:document_file))

          if @project_document.save
            format.html { redirect_back(fallback_location: root_path, notice: 'The document was successfully uploaded.') }
            format.json { render json: @project }
          else
            format.html { redirect_back(fallback_location: root_path, alert: @certification_path_document.errors['document_file'].first.to_s) }
            format.json { render json: @project['document_file'].to_s, status: :unprocessable_entity }
          end
        end
      end
    end

    def download_document
      begin
        send_file @document.document_file.path, x_sendfile: false
      rescue ActionController::MissingFile
        redirect_back(fallback_location: root_path, alert: 'This file is no longer available for download. This could be due to a detection of malware.')
      end
    end

    def destroy_document
      if @document.destroy
        redirect_back(fallback_location: root_path, notice: 'Document successfully deleted.')
      else
        redirect_back(fallback_location: root_path, alert: 'Document failed to delete.')
      end
    end

    private

    def set_controller_model
      @controller_model = @project
    end

    def set_project
      @project = Offline::Project.find(params[:id])
    end

    def set_project_document
      @document = Offline::ProjectDocument.find(params[:document_id])
    end

    def project_params
      params.require(:offline_project).permit(:name, :certificate_type, :code, :certified_area, :site_area, :developer, :description, :construction_year, :loc_as_per_directory)
    end
  end
end