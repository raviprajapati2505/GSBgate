module Offline
  class CertificationPathsController < AuthenticatedController
    load_and_authorize_resource param_method: :certification_path_params
    before_action :set_project
    before_action :set_controller_model, only: [:edit, :destroy, :show]
    before_action :set_certification_path, only: [:edit, :show, :destroy]

    def new
      @page_title = t('offline.certification_paths.form.title')
      @certification_path = Offline::CertificationPath.new
      @offline_scheme_mixes = @certification_path.offline_scheme_mixes.build
    end

    def create
      @certification_path = @project.offline_certification_paths.new(certification_path_params)
  
      if @certification_path.save
        redirect_to offline_project_certification_path(@project,@certification_path), notice: 'Certification created successfully.'
      else
        render :new
      end
    end

    def edit
      @page_title = t('offline.certification_paths.form.edit_title')
      @offline_scheme_mixes = @certification_path.offline_scheme_mixes
    end

    def update
      if @certification_path.update(certification_path_params)
        redirect_to offline_project_certification_path(@project,@certification_path), notice: 'Certification was successfully updated.'
      else
        render :edit
      end
    end

    def show
      @page_title = ERB::Util.html_escape(@certification_path.name.to_s)
    end

    def confirm_destroy
      @page_title = ERB::Util.html_escape(@certification_path.name.to_s)
    end

    def destroy
      if @certification_path.destroy
        redirect_to offline_project_path(@project), notice: 'The Certification was successfully removed.'
      else
        redirect_to offline_project_path(@project), alert: 'An error occurred when trying to remove the project. Please try again later.'
      end
    end

    private

    def set_controller_model
      @controller_model = @certification_path
    end

    def set_certification_path
      @certification_path = Offline::CertificationPath.find(params[:id])
    end

    def set_project
      @project = Offline::Project.find(params[:project_id])
    end

    def certification_path_params
      params.require(:offline_certification_path).permit(
        :name, 
        :version, 
        :development_type, 
        :rating, 
        :status,
        :score,
        :certified_at,
        offline_scheme_mixes_attributes: [
          :id,
          :name,
          :weight
        ]
      )
    end
  end
end