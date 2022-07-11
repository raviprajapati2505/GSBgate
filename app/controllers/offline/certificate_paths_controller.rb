module Offline
  class CertificatePathsController < AuthenticatedController
    load_and_authorize_resource param_method: :certificate_path_params
    before_action :set_project
    before_action :set_controller_model, only: [:edit, :update, :show]

    def new
      @page_title = t('offline.certificate_paths.form.title')
      @certificate_path = Offline::CertificatePath.new
      @offline_scheme_mixes = @certificate_path.offline_scheme_mixes.build
    end

    def create
      @certificate_path = @project.offline_certificate_paths.build(certificate_path_params)
  
      if @certificate_path.save
        redirect_to offline_project_certificate_path(@project,@certificate_path), notice: 'Certificate created successfully.'
      else
        render :new
      end
    end

    private

    def set_controller_model
      @controller_model = @certificate_path
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
          :offline_certificate_path_id,
          :name
        ]
      )
    end

  end
end