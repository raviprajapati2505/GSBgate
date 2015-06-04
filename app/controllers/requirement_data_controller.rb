class RequirementDataController < AuthenticatedController
  before_action :set_requirement_datum
  load_and_authorize_resource

  def update
    case @requirement_datum.reportable_data_type
      when 'CalculatorDatum'
        @requirement_datum.reportable_data.field_data.each do |field_datum|
          if params["field-data-#{field_datum.id}"]
            field_datum.value = params["field-data-#{field_datum.id}"]
            field_datum.save
          end
        end
      when 'DocumentDatum'
        # todo
    end

    render json: @requirement_datum, status: :ok
  end

  private
  def set_requirement_datum
    @requirement_datum = RequirementDatum.find(params[:id])
  end
end