class ProjectAuthorizationsController < AuthenticatedController
  load_and_authorize_resource
  before_action :set_project, only: [:new, :create, :edit, :destroy]
  before_action :set_authorization, only: [:edit, :destroy]

  def new
    authorize! :manage, @project
    @project_authorization = ProjectAuthorization.new(project: @project)
    if current_user.system_admin? && params.has_key?(:query) && params[:query] == 'certifiers'
      @show_certifiers = true
    end
  end

  def create
    authorize! :manage, @project
    @project_authorization = ProjectAuthorization.new(authorizations_params)
    @project_authorization.project = @project
    if @project_authorization.save
      flash[:notice] = 'Member was successfully added.'
      redirect_to project_path id: @project.id
    else
      render action: :new
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
    if @project_authorization.update(authorizations_params)
      flash[:notice] = 'Authorization was successfully updated.'
      redirect_to project_path(@project_authorization.project)
    else
      render action: :edit
    end
  end

  def destroy
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

    id = @project_authorization.project_id
    @project_authorization.destroy
    flash[:notice] = 'Authorization was successfully destroyed.'
    redirect_to project_path id: id
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
