class CertificationPathsController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path, only: [:show]
  load_and_authorize_resource

  def index
    @certification_paths = CertificationPath.all
  end

  def show
    redirect_to project_certification_path_scheme_mix_path(@project, @certification_path, @certification_path.scheme_mixes.take) if @certification_path.has_fixed_scheme?
    @page_title = "#{@certification_path.certificate.label} for #{@project.name}"
  end

  def new
    authorize! :manage, @project
    @certification_path = CertificationPath.new(project: @project)
  end

  def create
    authorize! :manage, @project
    CertificationPath.transaction do
      @certification_path = CertificationPath.new(certification_path_params)
      @certification_path.registered!
      @certification_path.project = @project
      if @certification_path.certificate_id == Certificate.where('label = ?', 'Operations Certificate').first.id
        if @certification_path.save
          SchemeMix.create(certification_path_id: @certification_path.id, scheme_id: Scheme.where('label = ?', 'Operations').first.id, weight: 100)
          flash[:notice] = 'Successfully applied for certificate.'
          redirect_to project_certification_path_path(@project, @certification_path)
        else
          render action: :new
        end
      else
        flash[:notice] = 'This certificate is not yet available.'
        render action: :new
      end
    end
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
