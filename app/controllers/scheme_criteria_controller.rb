class SchemeCriteriaController < AuthenticatedController
  load_and_authorize_resource :scheme_criterion

  def index
    respond_to do |format|
      format.html {
        @page_title = 'Criteria'
        @datatable = Effective::Datatables::SchemeCriteria.new
        @datatable.current_ability = current_ability
        @datatable.table_html_class = 'table table-bordered table-striped table-hover'
      }
    end
  end

  def show
    @page_title = ERB::Util.html_escape(@scheme_criterion.full_name)
  end
end