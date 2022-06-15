class SurveyResponsesController < ApplicationController
  before_action :set_project_survey, only: [:new, :create, :thank_you]

  def new
    @survey_response = SurveyResponse.new
  end

  def create
    @survey_response = @project_survey.survey_responses.new(survey_response_params)
    if @survey_response.save
      redirect_to thank_you_survey_responses_path(@project_survey), notice: 'Response saved successfully !!'
    else
      render :new
    end
  end

  def thank_you
  end

  private

  def set_project_survey
    @project_survey = ProjectsSurvey.friendly.find(params[:project_survey_id])
  end

  def survey_response_params
    params.require(:survey_response).permit(:name, :email)
  end

end
