class ProjectsSurveysController < AuthenticatedController
  load_and_authorize_resource :project, param_method: :survey_params
  before_action :set_project_with_survey_type, except: [:index]
  before_action :set_project_survey, except: [:index, :new, :create]

  def index
    @page_title = t('project_surveys.index.title_html')
    @projects_surveys_datatable = Effective::Datatables::ProjectsSurveys.new
  end

  def show
    @page_title = @projects_survey.title
    @latest_questions = @projects_survey.survey_questionnaire_version&.survey_questions
  end

  def new
    @page_title = 'Surveys'
    @projects_survey = ProjectsSurvey.new
  end

  def copy_project_survey
    @page_title = 'Surveys'

    projects_survey = 
      ProjectsSurvey.new(
        title: @projects_survey.title,
        end_date: @projects_survey.end_date,
        user_access: @projects_survey.user_access,
        description: @projects_survey.description,
        submission_statement: @projects_survey.submission_statement
      )

      @projects_survey = projects_survey

      render :new
  end

  def create
    @projects_survey = @project.projects_surveys.new(survey_params)
  
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

  def export_survey_results
    filepath = filepath_for_report 'Survey Response Report'
    report = Reports::SurveyResponseReport.new(@projects_survey, @project)
    report.save_as(filepath)
    send_file filepath, :type => 'application/pdf', :x_sendfile => false
  end

  private 

  def survey_params
    params.
      require(:projects_survey).
      permit(
        :title, 
        :description, 
        :end_date, 
        :submission_statement, 
        :status, 
        :user_access, 
        :survey_type_id
      )
  end

  def set_project_survey
    @projects_survey = ProjectsSurvey.find(params[:id])
    @controller_model = @projects_survey
  end

  def set_project_with_survey_type
    @survey_types = SurveyType.released_survey_types
    @project = Project.find(params[:project_id])
  end

  def filepath_for_report(report_name)
    filename = "#{@project.code} - #{@projects_survey.title} - #{report_name}.pdf"
    Rails.root.join('private', 'projects', @project.id.to_s, 'survey_responses', @projects_survey.id.to_s, 'reports', filename)
  end
end
