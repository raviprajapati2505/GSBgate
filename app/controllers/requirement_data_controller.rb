class RequirementDataController < AuthenticatedController
  before_action :set_requirement_datum
  load_and_authorize_resource

  def update
    case @requirement_datum.reportable_data_type
      when 'CalculatorDatum'
        @requirement_datum.reportable_data.field_data.each do |field_datum|
          if params["field-datum-#{field_datum.id}"]
            field_datum.value = params["field-datum-#{field_datum.id}"]
            field_datum.save
          end
        end
      when 'DocumentDatum'
        document_datum = @requirement_datum.reportable_data
        if params["document-datum-#{document_datum.id}"]
          uploaded_io = params["document-datum-#{document_datum.id}"]
          File.open(Rails.root.join('private', 'uploads', uploaded_io.original_filename), 'wb') do |file|
            file.write(uploaded_io.read)
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