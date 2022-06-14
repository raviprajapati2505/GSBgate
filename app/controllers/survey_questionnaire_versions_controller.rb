class SurveyQuestionnaireVersionsController < AuthenticatedController
  load_and_authorize_resource class: false
  before_action :set_survey_type
  before_action :set_latest_survey_questionnaire_version, only: [:form, :update]
  before_action :set_latest_survey_questions, only: [:form]

  def show; end

  def form
    @survey_questions = @latest_survey_questionnaire_version.survey_questions.new unless @survey_questions.present?

    if @latest_survey_questionnaire_version.released?
      @submit_method = 'POST'
    else
      @submit_method = 'PATCH'
    end
  end

  def create
    @latest_survey_questionnaire_version = @survey_type.create_survey_questionnaire_version

    if @latest_survey_questionnaire_version.update(survey_questionnaire_version_params)
      redirect_to survey_type_survey_questionnaire_versions_path(@survey_type), notice: 'Survey questions was successfully created.'
    else
      render :form
    end
  end

  def update
    if @survey_questions = @latest_survey_questionnaire_version.update(survey_questionnaire_version_params)
      redirect_to survey_type_survey_questionnaire_versions_path(@survey_type), notice: 'Survey questions was successfully updated.'
    else
      render :form
    end
  end

  private

    def set_survey_type
      @survey_type = SurveyType.find(params[:survey_type_id])
    end

    def set_latest_survey_questionnaire_version
      @latest_survey_questionnaire_version = @survey_type.latest_survey_questionnaire_version
    end

    def set_latest_survey_questions
      @survey_questions = @survey_type.latest_survey_questions
    end

    def survey_questionnaire_version_params
      if params[:action] == 'create'
        params.require(:survey_questionnaire_version).permit(survey_questions_attributes: [:question_text, :description, :mandatory, :position, :question_type, :_destroy])
      else
        params.require(:survey_questionnaire_version).permit(survey_questions_attributes: [:id, :question_text, :description, :mandatory, :position, :question_type, :_destroy])
      end
    end
end
