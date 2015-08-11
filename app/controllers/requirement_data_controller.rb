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

    @requirement_datum.user = User.find(params[:user_id]) unless params[:user_id].blank?
    if params.has_key?(:due_date)
      if params[:due_date] != ''
        @requirement_datum.due_date = Date.strptime(params[:due_date], t('date.formats.short'))
      else
        @requirement_datum.due_date = nil
      end
    end

    @requirement_datum.status = params[:status]

    # If there was a user assigned to this requirement, notify him
    if @requirement_datum.user_id_changed?
      if @requirement_datum.due_date.nil?
        notify(body: 'Requirement %s is assigned to you.',
               body_params: [@requirement_datum.requirement.label],
               uri: project_certification_path_scheme_mix_scheme_mix_criterion_path(params[:project_id], params[:certification_path_id], params[:scheme_mix_id], params[:scheme_mix_criterion_id]) + '#requirement-' + @requirement_datum.id.to_s,
               user: @requirement_datum.user,
               project: @project)
      else
        notify(body: 'Requirement %s is assigned to you. The due date is %s.',
               body_params: [@requirement_datum.requirement.label, l(@requirement_datum.due_date, format: :short)],
               uri: project_certification_path_scheme_mix_scheme_mix_criterion_path(params[:project_id], params[:certification_path_id], params[:scheme_mix_id], params[:scheme_mix_criterion_id]) + '#requirement-' + @requirement_datum.id.to_s,
               user: @requirement_datum.user,
               project: @project)
      end
    # If the due date was changed, notify the assigned user
    elsif @requirement_datum.due_date_changed?
      if @requirement_datum.due_date.nil?
        notify(body: 'Due date for requirement %s is removed.',
               body_params: [@requirement_datum.requirement.label],
               uri: project_certification_path_scheme_mix_scheme_mix_criterion_path(params[:project_id], params[:certification_path_id], params[:scheme_mix_id], params[:scheme_mix_criterion_id]) + '#requirement-' + @requirement_datum.id.to_s,
               user: @requirement_datum.user,
               project: @project)
      else
        notify(body: 'Due date for requirement %s is changed to %s.',
               body_params: [@requirement_datum.requirement.label, l(@requirement_datum.due_date, format: :short)],
               uri: project_certification_path_scheme_mix_scheme_mix_criterion_path(params[:project_id], params[:certification_path_id], params[:scheme_mix_id], params[:scheme_mix_criterion_id]) + '#requirement-' + @requirement_datum.id.to_s,
               user: @requirement_datum.user,
               project: @project)
      end
    # If the status was changed, notify the project managers
    elsif @requirement_datum.status_changed?
      @project.managers.each do |project_manager|
        notify(body: 'The status of requirement %s is changed to %s.',
               body_params: [@requirement_datum.requirement.label, @requirement_datum.status.humanize],
               uri: project_certification_path_scheme_mix_scheme_mix_criterion_path(params[:project_id], params[:certification_path_id], params[:scheme_mix_id], params[:scheme_mix_criterion_id]) + '#requirement-' + @requirement_datum.id.to_s,
               user: project_manager,
               project: @project)
      end
    end

    @requirement_datum.save!

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