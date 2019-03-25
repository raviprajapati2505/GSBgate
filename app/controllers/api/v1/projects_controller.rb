class Api::V1::ProjectsController < Api::ApiController
  # load_and_authorize_resource
  # load_resource

  def index

  end

  def show
    @project = Project.accessible_by(current_ability).find_by(id: params[:id])
    if @project.nil?
      render json: {}, status: :not_found
    else
      render 'show', formats: :json
    end
  end
end