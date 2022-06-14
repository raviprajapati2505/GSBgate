class SurveyTypesController < AuthenticatedController
  load_and_authorize_resource param_method: :event_params
  before_action :set_survey_type, only: [:show, :edit, :update, :destroy]

  # GET /survey_types
  def index
    @survey_types = SurveyType.all
  end

  # GET /survey_types/1
  def show; end

  # GET /survey_types/new
  def new
    @survey_type = SurveyType.new
  end

  # GET /survey_types/1/edit
  def edit; end

  # POST /survey_types
  def create
    @survey_type = SurveyType.new(survey_type_params)
    if @survey_type.save
      redirect_to survey_types_path, notice: 'Survey type was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /survey_types/1
  def update
    if @survey_type.update(survey_type_params)
      redirect_to survey_types_path, notice: 'Survey type was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /survey_types/1
  def destroy
    @survey_type.destroy
    redirect_to survey_types_url, notice: 'Survey type was successfully destroyed.'
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_survey_type
      @survey_type = SurveyType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def survey_type_params
      params.require(:survey_type).permit(:title, :description)
    end
end
