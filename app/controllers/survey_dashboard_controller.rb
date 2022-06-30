class SurveyDashboardController < AuthenticatedController
  load_and_authorize_resource class: false

  def index
    @page_title = t('survey_dashboard.index.title_html')
    @survey_types = SurveyType.all
    @linkme_survey_count =  LinkmeSurvey.all.count
  end
end
