class ProjectAuthorizationsController < AuthenticatedController
  load_and_authorize_resource
  before_action :set_project, only: [:create, :edit, :destroy, :update]
  before_action :set_authorization, only: [:edit, :destroy]

  def create
    @project_authorization = ProjectAuthorization.new(authorizations_params)
    first_cert_mngr_assigned = !@project.certifier_manager_assigned? && @project_authorization.certifier_manager?
    @project_authorization.project = @project
    if @project_authorization.save
      # Update system admins task
      if first_cert_mngr_assigned
        CertificationPathTask.where(flow_index: 1, role: User.roles[:system_admin], project: @project).each do |task|
          task.flow_index = 2
          task.save!
        end
      end

      redirect_to project_path(@project), notice: 'Member was successfully added.'
    else
      redirect_to :back
    end
  end

  def edit
    if current_user.system_admin? && params.has_key?(:query) && params[:query] == 'certifiers'
      @show_certifiers = true
    end
  end

  def show
    redirect_to edit_project_authorization_path, status: 301
  end

  def update
    if @project.owner == @project_authorization.user
      raise CanCan::AccessDenied.new('Not Authorized to edit project owner role', :update, ProjectAuthorization)
    end

    if @project_authorization.update(authorizations_params)
      redirect_to project_path(@project_authorization.project), notice: 'Authorization was successfully updated.'
    else
      render action: :edit
    end
  end

  def destroy
    if @project.owner == @project_authorization.user
      raise CanCan::AccessDenied.new('Not Authorized to remove project owner from team', :destroy, ProjectAuthorization)
    end

    # remove user - requirement_data link
    requirement_data = @project_authorization.user.requirement_data.for_project(@project)
    requirement_data.each do |requirement_datum|
      requirement_datum.user = nil
      requirement_datum.save!
    end

    # remove user - scheme_mix_criteria link
    scheme_mix_criteria = @project_authorization.user.scheme_mix_criteria.for_project(@project)
    scheme_mix_criteria.each do |scheme_mix_criterion|
      scheme_mix_criterion.certifier = nil
      scheme_mix_criterion.save!
    end

    project = @project_authorization.project
    @project_authorization.destroy
    redirect_to project_path(project), notice: 'Member was successfully removed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_authorization
      @project_authorization = ProjectAuthorization.find(params[:id])
    end

    def authorizations_params
      params.require(:authorization).permit(:user_id, :role)
    end
end
