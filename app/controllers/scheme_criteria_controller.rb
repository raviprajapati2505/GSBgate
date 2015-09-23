class SchemeCriteriaController < AuthenticatedController
  before_action :set_scheme_criterion, only: [:show]
  load_and_authorize_resource

  def index
    @page_title = 'Criteria'
    @default_values = {certificate_id: '', scheme_name: '', scheme_category_name: ''}
    @scheme_criteria = SchemeCriterion

    # Certificate filter
    if params[:scheme_category_name].present?
      @scheme_criteria = @scheme_criteria.joins(:scheme_category).where('scheme_categories.name ILIKE ?', "%#{params[:scheme_category_name]}%")
      @default_values[:scheme_category_name] = params[:scheme_category_name]
    end

    # Certificate filter
    if params[:scheme_name].present?
      @scheme_criteria = @scheme_criteria.joins(scheme_category: [:scheme]).where('schemes.name ILIKE ?', "%#{params[:scheme_name]}%")
      @default_values[:scheme_name] = params[:scheme_name]
    end

    # Certificate filter
    if params[:certificate_id].present? and (params[:certificate_id].to_i > 0)
      @scheme_criteria = @scheme_criteria.joins(scheme_category: [:scheme]).where(schemes: {certificate_id: params[:certificate_id].to_i})
      @default_values[:certificate_id] = params[:certificate_id]
    end

    @scheme_criteria = @scheme_criteria.paginate page: params[:page], per_page: 25
  end

  def show
    @page_title = @scheme_criterion.full_name
  end

  private

  def set_scheme_criterion
    @scheme_criterion = SchemeCriterion.find(params[:id])
    @controller_model = @scheme_criterion
  end
end