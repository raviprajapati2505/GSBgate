class SurveyTypesController < AuthenticatedController
  load_and_authorize_resource param_method: :survey_type_params
  before_action :set_survey_type, only: [:show, :edit, :update, :destroy]

  def index
    @page_title = t('survey_type.index.title_html')
    @survey_types = SurveyType.all
  end

  def show
    @page_title = @survey_type.title
    @survey_questionnaire_version = @survey_type.latest_survey_questionnaire_version
    @survey_questions = @survey_type.latest_survey_questions
    @is_latest = true
  end

  def new
    @survey_type = SurveyType.new
  end

  def edit; end

  def create
    @survey_type = SurveyType.new(survey_type_params)
    if @survey_type.save
      redirect_to survey_types_path, notice: 'Survey type was successfully created.'
    else
      render :new
    end
  end

  def update
    if @survey_type.update(survey_type_params)
      redirect_to survey_types_path, notice: 'Survey type was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @survey_type.destroy
    redirect_to survey_types_url, notice: 'Survey type was successfully destroyed.'
  end

  private

    def set_survey_type
      @survey_type = SurveyType.find(params[:id])
      @controller_model = @survey_type
    end

    def survey_type_params
      params.
        require(:survey_type).
        permit(
          :title, 
          :description
        )
    end
end
