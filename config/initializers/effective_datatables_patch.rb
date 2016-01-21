Rails.application.config.after_initialize do

  Effective::DatatablesController.class_eval do
    def show
      @datatable = find_datatable(params[:id]).try(:new, params[:attributes])
      @datatable.current_ability = current_ability
      @datatable.view = view_context if !@datatable.nil?

      EffectiveDatatables.authorized?(self, :index, @datatable.try(:collection_class) || @datatable.try(:class))

      respond_to do |format|
        format.html
        format.json {
          if Rails.env.production?
            render :json => (@datatable.to_json rescue error_json)
          else
            render :json => @datatable.to_json
          end
        }
      end
    end
  end

end