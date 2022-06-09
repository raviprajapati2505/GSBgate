class SurveyTypesController < AuthenticatedController
  before_action :set_survey_type, only: [:show, :edit, :update, :destroy]

  # GET /survey_types
  # GET /survey_types.json
  def index
    @survey_types = SurveyType.all
  end

  # GET /survey_types/1
  # GET /survey_types/1.json
  def show
  end

  # GET /survey_types/new
  def new
    @survey_type = SurveyType.new
  end

  # GET /survey_types/1/edit
  def edit
  end

  # POST /survey_types
  # POST /survey_types.json
  def create
    @survey_type = SurveyType.new(survey_type_params)

    respond_to do |format|
      if @survey_type.save
        format.html { redirect_to survey_types_path, notice: 'Survey type was successfully created.' }
        format.json { render :show, status: :created, location: @survey_type }
      else
        format.html { render :new }
        format.json { render json: @survey_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /survey_types/1
  # PATCH/PUT /survey_types/1.json
  def update
    respond_to do |format|
      if @survey_type.update(survey_type_params)
        format.html { redirect_to survey_types_path, notice: 'Survey type was successfully updated.' }
        format.json { render :show, status: :ok, location: @survey_type }
      else
        format.html { render :edit }
        format.json { render json: @survey_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /survey_types/1
  # DELETE /survey_types/1.json
  def destroy
    @survey_type.destroy
    respond_to do |format|
      format.html { redirect_to survey_types_url, notice: 'Survey type was successfully destroyed.' }
      format.json { head :no_content }
    end
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
