class CertificationPathsController < ApplicationController
  before_action :set_project, only: [:show, :index, :new, :create]
  before_action :set_certification_path, only: [:show, :edit, :update, :destroy]

  def index
    @certification_paths = CertificationPath.all
  end

  def show
  end

  def new
    @certification_path = CertificationPath.new(project: @project)
  end

  def edit
  end

  def create
    @certification_path = CertificationPath.new(certification_path_params)
    @certification_path.project = @project
    if @certification_path.save
      flash[:notice] = 'Certification path was successfully created.'
      redirect_to project_path(@project)
    else
      render action: :new
    end
  end

  def update
    if @certification_path.update(certification_path_params)
      flash[:notice] = 'Certification path was successfully updated.'
    else
      format.html { render :edit }
    end
  end

  def destroy
    @certification_path.destroy
    flash[:notice] = 'Certification path was successfully destroyed.'
  end

  private
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_certification_path
      @certification_path = CertificationPath.find(params[:id])
    end

    def certification_path_params
      params.require(:certification_path).permit(:certificate_id)
    end
end
