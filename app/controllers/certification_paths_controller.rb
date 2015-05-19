class CertificationPathsController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

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
    if @certification_path.certificate_id == Certificate.where('label = ?', 'Operations Certificate').first.id
      if @certification_path.save
        @scheme_mix = SchemeMix.new(certification_path_id: @certification_path.id, scheme_id: Scheme.where('label = ?', 'Operations').first.id, weight: 100)
        @scheme_mix.save
        flash[:notice] = 'Certification path was successfully created.'
        redirect_to project_path(@project)
      else
        render action: :new
      end
    else
      flash[:notice] = 'This certification path is not yet available.'
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
