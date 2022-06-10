class SurveyQuestionsController < AuthenticatedController
  load_and_authorize_resource param_method: :survey_question_params
  before_action :set_survey_question, only: [:show, :edit, :update, :destroy]

  # GET /survey_questions
  def index
    @survey_questions = SurveyQuestion.all
  end

  # GET /survey_questions/1
  def show; end

  # GET /survey_questions/new
  def new
    @survey_question = SurveyQuestion.new
  end

  # GET /survey_questions/1/edit
  def edit; end

  # POST /survey_questions
  def create
    @survey_question = SurveyQuestion.new(survey_question_params)

    if @survey_question.save
      redirect_to @survey_question, notice: 'Survey question was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /survey_questions/1
  def update
    if @survey_question.update(survey_question_params)
      redirect_to @survey_question, notice: 'Survey question was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /survey_questions/1
  def destroy
    @survey_question.destroy
    redirect_to survey_questions_url, notice: 'Survey question was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_survey_question
      @survey_question = SurveyQuestion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def survey_question_params
      params.require(:survey_question).permit(:question_text, :description, :mandatory, :position, :question_type, :survey_questionnaire_version_id)
    end
end
