class SchemeCriteriaController < AuthenticatedController
  before_action :set_scheme_criterion, only: [:show]
  load_and_authorize_resource

  def index
    @page_title = 'Criteria'
    @default_values = {certificate_id: '', scheme_name: '', scheme_category_name: ''}
    @scheme_criteria = SchemeCriterion.includes(scheme_category: [:scheme])

    # Catergory filter
    if params[:scheme_category_name].present?
      @scheme_criteria = @scheme_criteria.where('scheme_categories.name ILIKE ?', "%#{params[:scheme_category_name]}%")
      @default_values[:scheme_category_name] = params[:scheme_category_name]
    end

    # Scheme filter
    if params[:scheme_name].present?
      @scheme_criteria = @scheme_criteria.where('schemes.name ILIKE ?', "%#{params[:scheme_name]}%")
      @default_values[:scheme_name] = params[:scheme_name]
    end

    # Certificate filter
    if params[:certificate_id].present? && (params[:certificate_id].to_i > 0)
      @scheme_criteria = @scheme_criteria.where(schemes: {certificate_id: params[:certificate_id].to_i})
      @default_values[:certificate_id] = params[:certificate_id]
    end

    @scheme_criteria = @scheme_criteria.order('scheme_categories.code', 'number', 'schemes.certificate_id').page(params[:page]).per(25)
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