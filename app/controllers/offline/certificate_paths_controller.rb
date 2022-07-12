module Offline
  class CertificatePathsController < AuthenticatedController
    load_and_authorize_resource param_method: :certificate_path_params
    before_action :set_project
    before_action :set_controller_model, only: [:edit, :destroy, :show]
    before_action :set_certificate_path, only: [:edit, :show, :destroy]

    def new
      @page_title = t('offline.certificate_paths.form.title')
      @certificate_path = Offline::CertificatePath.new
      @offline_scheme_mixes = @certificate_path.offline_scheme_mixes.build
    end

    def create
      @certificate_path = @project.offline_certificate_paths.new(certificate_path_params)
  
      if @certificate_path.save
        redirect_to offline_project_certificate_path(@project,@certificate_path), notice: 'Certification created successfully.'
      else
        render :new
      end
    end

    def edit
      @page_title = t('offline.certificate_paths.form.edit_title')
      @offline_scheme_mixes = @certificate_path.offline_scheme_mixes
    end

    def update
      if @certificate_path.update(certificate_path_params)
        redirect_to offline_project_certificate_path(@project,@certificate_path), notice: 'Certification was successfully updated.'
      else
        render :new
      end
    end

    def show
      @page_title = ERB::Util.html_escape(@certificate_path.name.to_s)
    end

    def confirm_destroy
      @page_title = ERB::Util.html_escape(@certificate_path.name.to_s)
    end

    def destroy
      if @certificate_path.destroy
        redirect_to offline_project_path(@project), notice: 'The Certification was successfully removed.'
      else
        redirect_to offline_project_path(@project), alert: 'An error occurred when trying to remove the project. Please try again later.'
      end
    end

    private

    def set_controller_model
      @controller_model = @certificate_path
    end

    def set_certificate_path
      @certificate_path = Offline::CertificatePath.find(params[:id])
    end

    def set_project
      @project = Offline::Project.find(params[:project_id])
    end

    def certificate_path_params
      params.require(:offline_certificate_path).permit(
        :name, 
        :version, 
        :development_type, 
        :rating, 
        :status,
        :score,
        :certified_at,
        offline_scheme_mixes_attributes: [
          :id,
          :name
        ]
      )
    end

  end
end