class SchemeMixesController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path
  before_action :set_scheme_mix
  load_and_authorize_resource

  def show
    @page_title = @scheme_mix.scheme.full_label
  end

  def allocate_project_team_responsibility
    if params.has_key?(:requirement_data)
      # Format the user id
      if params[:user_id].empty?
        user_id = nil
      else
        user_id = params[:user_id]
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

      # Update all requirements
      RequirementDatum.where(id: params[:requirement_data]).update_all(user_id: user_id, due_date: due_date, status: status)

      # TODO: Notify the allocated user
      # if user_id
      #   requirement_data = RequirementDatum.find(params[:requirement_data])
      #   user = User.find(user_id)
      #
      #   requirement_data.each do |requirement_datum|
      #     if due_date
      #       notify(body: 'Requirement %s is assigned to you. The due date is %s.',
      #              body_params: [requirement_datum.requirement.label, l(requirement_datum.due_date, format: :short)],
      #              uri: project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, params[:scheme_mix_criterion_id]) + '#requirement-' + requirement_datum.id.to_s,
      #              user: user,
      #              project: @project)
      #     else
      #       notify(body: 'Requirement %s is assigned to you.',
      #              body_params: [requirement_datum.requirement.label],
      #              uri: project_certification_path_scheme_mix_scheme_mix_criterion_path(@project, @certification_path, @scheme_mix, params[:scheme_mix_criterion_id]) + '#requirement-' + requirement_datum.id.to_s,
      #              user: user,
      #              project: @project)
      #     end
      #   end
      # end

      # TODO: Create tasks for the allocated user

      flash[:notice] = 'The selected requirements were successfully updated.'
    else
      flash[:alert] = 'No requirements were selected.'
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
