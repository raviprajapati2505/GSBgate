class SchemeMixesController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path
  before_action :set_scheme_mix, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  def index
    @scheme_mixes = SchemeMix.all
  end

  def show
    @page_title = @scheme_mix.scheme.full_label
  end

  def new
    @scheme_mix = SchemeMix.new(certification_path: @certification_path)
  end

  def edit
  end

  def create
    @scheme_mix = SchemeMix.new(scheme_mix_params)
    @scheme_mix.certification_path = @certification_path
    if @scheme_mix.save
      flash[:notice] = 'Scheme mix was successfully created.'
      redirect_to certification_path_path(@certification_path)
    else
      render action: :new
    end
  end

  def update
    if @scheme_mix.update(scheme_mix_params)
      flash[:notice] = 'Scheme mix was successfully updated.'
    else
      format.html { render :edit }
    end
  end

  def destroy
    @scheme_mix.destroy
    flash[:notice] = 'Scheme mix was successfully destroyed.'
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

    def scheme_mix_params
      params.require(:scheme_mix).permit(:scheme_id, :weight)
    end
end
