class SchemeMixesController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path
  before_action :set_scheme_mix
  load_and_authorize_resource

  def show
    @page_title = @scheme_mix.scheme.full_name
  end

  def allocate_project_team_responsibility
    if params.has_key?(:requirement_data)
      # Format the user id
      if params[:user_id].empty?
        user = nil
      else
        user = User.find(params[:user_id])
      end

      # Format the due date
      if params[:due_date].empty?
        due_date = nil
      else
        due_date = Date.strptime(params[:due_date], t('date.formats.short'))
      end

      # Format the status
      if params[:status].empty?
        status = nil
      else
        status = params[:status]
      end

      # Load the RequirementDatum models
      requirement_data = RequirementDatum.find(params[:requirement_data])

      # Update the RequirementDatum models
      requirement_data.each do |requirement_datum|
        requirement_datum.update!(user: user, due_date: due_date, status: status)
      end

      flash[:notice] = 'The selected requirements were successfully updated.'
    else
      flash[:alert] = 'No requirements were selected.'
    end

    redirect_to project_certification_path_scheme_mix_path(@certification_path.project, @certification_path, @scheme_mix)
  end

  def allocate_certifier_team_responsibility
    if params.has_key?(:scheme_mix_criteria)
      # Format the certifier id
      if params[:certifier_id].empty?
        certifier = nil
      else
        certifier = User.find(params[:certifier_id])
      end

      # Format the due date
      if params[:due_date].empty?
        due_date = nil
      else
        due_date = Date.strptime(params[:due_date], t('date.formats.short'))
      end

      # Load the SchemeMixCriteria models
      scheme_mix_criteria = SchemeMixCriterion.find(params[:scheme_mix_criteria])

      # Update the SchemeMixCriteria models
      scheme_mix_criteria.each do |scheme_mix_criterion|
        scheme_mix_criterion.update!(certifier: certifier, due_date: due_date)
      end

      flash[:notice] = 'The selected criteria were successfully updated.'
    else
      flash[:alert] = 'No criteria were selected.'
    end

    redirect_to project_certification_path_scheme_mix_path(@certification_path.project, @certification_path, @scheme_mix)
  end

  private
  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_certification_path
    @certification_path = CertificationPath.find(params[:certification_path_id])
  end

  def set_scheme_mix
    @scheme_mix = SchemeMix.find(params[:id])
  end
end
