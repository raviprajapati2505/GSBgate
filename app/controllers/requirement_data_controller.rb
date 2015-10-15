class RequirementDataController < AuthenticatedController
  require_dependency 'reflection'

  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project
  load_and_authorize_resource :scheme_mix, :through => :certification_path
  load_and_authorize_resource :scheme_mix_criterion, :through => :scheme_mix
  load_and_authorize_resource :requirement_datum, :through => :scheme_mix_criterion
  before_action :set_controller_model, except: [:new, :create]

  def update
    if @requirement_datum.calculator_datum.present?
      @requirement_datum.calculator_datum.field_data.each do |field_datum|
        if params["field-datum-#{field_datum.id}"]
          field_datum.value = params["field-datum-#{field_datum.id}"]
          unless field_datum.valid?
            # set value to nil otherwise 0 is used in case of integer_value
            field_datum.value = nil
            @certification_path_id = params[:certification_path_id]
            @scheme_mix_id = params[:scheme_mix_id]
            @scheme_mix_criterion_id = params[:scheme_mix_criterion_id]
            render 'update' and return
          end
          field_datum.save
        end
      end

      # Instantiate the calculator class
      calculator_name = @requirement_datum.calculator_datum.calculator.name
      if Reflection.class_exists calculator_name
        calculator = calculator_name.constantize.new
      else
        calculator = "Calculator::GsasServiceCalculator".constantize.new calculator_name
      end
      # Create the calculator parameter hash
      calculator_params = {}
      @requirement_datum.calculator_datum.field_data.each do |field_datum|
        field_name = field_datum.field.name
        calculator_params[field_name] = field_datum.value
      end
      # Call the calculate method on the calculator class
      @calculation_result = calculator.calculate calculator_params
    end

    unless params[:user_id].blank? || (!@requirement_datum.user.nil? && params[:user_id] == @requirement_datum.user.id)
      @requirement_datum.user = User.find(params[:user_id])
    end

    if params.has_key?(:due_date)
      if params[:due_date] != ''
        @requirement_datum.due_date = Date.strptime(params[:due_date], t('date.formats.short'))
      else
        @requirement_datum.due_date = nil
      end
    end

    @requirement_datum.status = params[:status]

    @requirement_datum.save!

    @certification_path_id = params[:certification_path_id]
    @scheme_mix_id = params[:scheme_mix_id]
    @scheme_mix_criterion_id = params[:scheme_mix_criterion_id]

    flash.now[:notice] = 'Requirement was successfully updated.'

    render 'update'
  end

  def refuse
    if (current_user == @requirement_datum.user)
      @requirement_datum.update(user: nil, audit_log_user_comment: params[:audit_log_user_comment])
      redirect_to :back, notice: 'You are now unassigned from this requirement.'
    else
      redirect_to :back, alert: 'Only the assigned user can refuse this requirement.'
    end
  end

  private
  def set_controller_model
    @controller_model = @requirement_datum
  end
end