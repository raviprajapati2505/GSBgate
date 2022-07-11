module Offline
  class ProjectsController < AuthenticatedController
    include ActionView::Helpers::TranslationHelper
    load_and_authorize_resource param_method: :project_params
    before_action :set_controller_model, only: [:edit, :update, :show, :destroy]
    before_action :set_project, only: [:edit, :update, :show, :destroy, :upload_documents]

    def index
      @page_title = t('offline.projects.index.title_html')
      @datatable = Effective::Datatables::OfflineProjects.new
    end

    def new
      @page_title = t('offline.projects.index.btn_new_project')
      @project = Offline::Project.new
    end

    def create
      # respond_to do |format|
      #   @project = Offline::Project.new(project_params)
      #   if params.has_key?(:offline_project)
      #     if @project.save
      #       format.html { redirect_back(fallback_location: offline_projects_path, notice: 'The Project was successfully created.') }
      #       format.json { render json: @project }
      #     else
      #       format.html { render :new }
      #       format.json { render json: @project['documents'].to_s }
      #     end
      #   end
      # end
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
          binding.pry
          @project.documents = params[:offline_project][:documents]
          if @project.save
            format.html { redirect_back(fallback_location: @project, notice: 'The document was successfully uploaded.') }
            format.json { render json: @project }
          else
            format.html { redirect_back(fallback_location: @project, alert: @project.errors['documents'].first.to_s) }
            format.json { render json: @project['documents'].to_s, status: :unprocessable_entity }
          end
        end
      end
    end

    private
    def set_controller_model
      @controller_model = @project
    end

    def set_project
      @project = Offline::Project.find(params[:id])
    end

    def project_params
      params.require(:offline_project).permit(:name, :certificate_type, :code, :certified_area, :site_area, :developer, :description, :construction_year, documents: [])
    end

  end
end