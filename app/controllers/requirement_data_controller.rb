class RequirementDataController < AuthenticatedController
  before_action :set_requirement_datum
  load_and_authorize_resource

  def update
    if @requirement_datum.calculator_datum.present?
      @requirement_datum.calculator_datum.field_data.each do |field_datum|
        if params["field-datum-#{field_datum.id}"]
          field_datum.value = params["field-datum-#{field_datum.id}"]
          field_datum.save
        end
      end
    end

    @requirement_datum.user = User.find(params[:user_id])
    @requirement_datum.save!

    render json: @requirement_datum, status: :ok
  end

  private
  def set_requirement_datum
    @requirement_datum = RequirementDatum.find(params[:id])
  end
end