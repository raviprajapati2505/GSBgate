module Offline
  class SchemeMixesController < AuthenticatedController
    load_and_authorize_resource param_method: :scheme_mix_params
    before_action :set_project_certification_path
    before_action :set_scheme_mix
    before_action :set_controller_model, only: [:show,:edit_criterion]

    def edit_criterion
      @page_title = t('offline.scheme_mixes.form.edit_title')
      @offline_scheme_mix_criteria = @scheme_mix.offline_scheme_mix_criteria
    end

    def update_criterion
      if @scheme_mix.update(scheme_mix_params)
        redirect_to offline_project_certification_scheme_path(@project, @certification_path, @scheme_mix), notice: 'Criteria updated successfully.'
      else
        render :edit_criterion
      end
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

    def scheme_mix_params
      params.require(:offline_scheme_mix).permit(
        offline_scheme_mix_criteria_attributes: [
          :id,
          :name,
          :score,
          :code,
          :_destroy
        ]
      )
    end
  end
end