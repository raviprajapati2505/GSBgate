module Offline
  class SchemeMixesController < AuthenticatedController
    before_action :set_project_certification_path
    before_action :set_scheme_mix, only: [:show]
    before_action :set_controller_model, only: [:show]

    def new
      @page_title = t('offline.scheme_mixes.form.title')
      @scheme_mix = Offline::SchemeMix.new
      @offline_scheme_mix_criterion = @scheme_mix.offline_scheme_mix_criteria.build
    end

    def create
    end

    def show
      @page_title = ERB::Util.html_escape(@scheme_mix.name.to_s)
    end

    private

    def set_controller_model
      @controller_model = @scheme_mix
    end
    
    def set_project_certification_path
      @project = Offline::Project.find(params[:project_id])
      @certification_path = Offline::CertificationPath.find(params[:certification_id])
    end

    def set_scheme_mix
      @scheme_mix = Offline::SchemeMix.find(params[:id])
    end
  end
end