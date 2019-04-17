class SchemeCategoriesController < AuthenticatedController
  before_action :set_scheme_category, only: [:edit, :update, :destroy]
  load_and_authorize_resource

  def show
    @page_title = "#{ERB::Util.html_escape(@scheme_category.code)}: #{ERB::Util.html_escape(@scheme_category.name)}"
  end

  def edit
    @page_title = "Edit #{ERB::Util.html_escape(@scheme_category.code)}: #{ERB::Util.html_escape(@scheme_category.name)}"
  end

  def update
    if @scheme_category.update(scheme_category_params)
      redirect_to scheme_category_path(@scheme_category), notice: 'Category was successfully updated.'
    else
      redirect_to scheme_category_path(@scheme_category), alert: 'Category could not be updated.'
    end
  end

  def sort
    params[:sort_order].each do |key, value|
      SchemeCategory.find(value[:id]).update_attribute(:display_weight, value[:display_weight])
    end
    render body: nil
  end

  private

  def set_scheme_category
    @controller_model = @scheme_category
  end

  def scheme_category_params
    params.require(:scheme_category).permit(:name)
  end
end