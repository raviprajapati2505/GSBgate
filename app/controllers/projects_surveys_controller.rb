class ProjectsSurveysController < AuthenticatedController
  load_and_authorize_resource param_method: :survey_params
  before_action :set_project_with_survey_type, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_project_survey, only: [:show, :edit, :update, :destroy]

  def index; end

  def show
    @page_title = @projects_survey.title
    @latest_questions = @projects_survey.survey_questionnaire_version&.survey_questions
  end

  def new
    @page_title = 'Surveys'
    @projects_survey = ProjectsSurvey.new
  end

  def create
    @projects_survey = @project.projects_surveys.new(survey_params)
    @projects_survey.created_by = current_user
  
    if params[:button].present? && params[:button] == 'save-and-release'
      @projects_survey.released_at = Time.now
    end

    if @projects_survey.save
      redirect_to project_path(@project), notice: 'Survey created successfully.'
    else
      render :new
    end
  end

  def edit; end

  def update
    if params[:button].present? && params[:button] == 'save-and-release'
      @projects_survey.released_at = Time.now
    end

    if @projects_survey.update(survey_params)
      redirect_to project_path(@project), notice: 'Survey was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @projects_survey.destroy
    redirect_to project_path(@project), notice: 'Survey was successfully destroyed.'
  end

  private 

  def survey_params
    params.require(:projects_survey).permit(:title, :description, :end_date, :submission_statement, :status, :user_access, :survey_type_id)
  end

  def set_project_survey
    @projects_survey = ProjectsSurvey.find(params[:id])
    @controller_model = @projects_survey
  end

  def set_project_with_survey_type
    @survey_types = SurveyType.all
    @project = Project.find(params[:project_id])
  end
end
