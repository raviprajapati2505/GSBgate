class SurveyDashboardController < AuthenticatedController
  load_and_authorize_resource class: false

  def index
    @page_title = t('survey_dashboard.index.title_html')
    @survey_types_count = SurveyType.count
    @linkme_survey_count =  LinkmeSurvey.count
    @projects_surveys_count =  ProjectsSurvey.count
  end
end
