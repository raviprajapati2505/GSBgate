class RequirementDataController < AuthenticatedController
  require_dependency 'reflection'

  before_action :set_project
  before_action :set_requirement_datum
  load_and_authorize_resource

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
            render 'requirements/update' and return
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
      assign_to_user = User.find(params[:user_id])
      # Generate tasks for assigned users
      RequirementDatumTask.where(requirement_datum: @requirement_datum).each do |task|
        task.flow_index = 4
        task.project_role = nil
        task.user = assign_to_user
        task.save!
      end
      @requirement_datum.user = assign_to_user
    end

    if params.has_key?(:due_date)
      if params[:due_date] != ''
        @requirement_datum.due_date = Date.strptime(params[:due_date], t('date.formats.short'))
      else
        @requirement_datum.due_date = nil
      end
    end

    @requirement_datum.status = params[:status]

    # If the status was changed
    if @requirement_datum.status_changed?
      # Generate tasks for project managers
      unless @requirement_datum.required?
        RequirementDatumTask.where(flow_index: 3, project_role: ProjectAuthorization.roles[:project_manager], project: @project, requirement_datum: @requirement_datum).each do |task|
          task.destroy
        end
        requirement_processed = true
      end
    end

    @requirement_datum.save!

    if requirement_processed
      # Generate tasks for project managers
      scheme_mix_criterion = SchemeMixCriterion.find(params[:scheme_mix_criterion_id])
      unless scheme_mix_criterion.nil? || scheme_mix_criterion.requirement_data.required.count.nonzero?
        SchemeMixCriterionTask.create!(flow_index: 5, project_role: ProjectAuthorization.roles[:project_manager], project: @project, scheme_mix_criterion: scheme_mix_criterion)
      end
    end

    @certification_path_id = params[:certification_path_id]
    @scheme_mix_id = params[:scheme_mix_id]
    @scheme_mix_criterion_id = params[:scheme_mix_criterion_id]

    flash.now[:notice] = 'Requirement was successfully updated.'

    render 'requirements/update'
  end

  private
  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_requirement_datum
    @requirement_datum = RequirementDatum.find(params[:id])
  end
end