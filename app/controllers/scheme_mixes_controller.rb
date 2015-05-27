class SchemeMixesController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path
  before_action :set_scheme_mix
  load_and_authorize_resource

  def show
    @page_title = @scheme_mix.scheme.full_label
    @scheme_mix_criteria_by_categories = {}

    @scheme_mix.scheme_mix_criteria.each do |scheme_mix_criterion|
      unless @scheme_mix_criteria_by_categories.has_key?(scheme_mix_criterion.scheme_criterion.criterion.category.id)
        @scheme_mix_criteria_by_categories[scheme_mix_criterion.scheme_criterion.criterion.category.id] = []
      end

      @scheme_mix_criteria_by_categories[scheme_mix_criterion.scheme_criterion.criterion.category.id] << scheme_mix_criterion
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
    @scheme_mix = SchemeMix.find(params[:id])
  end

end
