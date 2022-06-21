class SurveyResponsesController < ApplicationController
  load_and_authorize_resource param_method: :survey_response_params, except: [:all_text_responses_of_survey_question]
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

  def thank_you; end

  def all_text_responses_of_survey_question
   question = SurveyQuestion.find_by(id: params[:question_id]);
   
    respond_to do |format|
      format.json { render json: question.question_responses }
    end
  end

  private

  def set_project_survey
    @project_survey = ProjectsSurvey.friendly.find(params[:project_survey_id])
    @survey_questions = @project_survey.survey_questionnaire_version&.survey_questions
  end

  def survey_response_params
    params.require(:survey_response).permit(:name, :email, question_responses_attributes: [:value, :survey_question_id])
  end

end
