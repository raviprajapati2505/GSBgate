class SurveyResponsesController < AuthenticatedController
  before_action :set_project_survey

  def new
    @survey_response = SurveyResponse.new
  end

  def create
    @survey_response = @project_survey.survey_responses.new(survey_response_params)
    if @survey_response.save
      redirect_to survey_types_path, notice: 'Survey type was successfully created.'
    else
      render :new
    end
  end

  private

  def set_project_survey
    @project_survey = ProjectsSurvey.find(params[:survey_id])
  end

  def survey_response_params
    params.require(:survey_response).permit(:name, :email)
  end

end
