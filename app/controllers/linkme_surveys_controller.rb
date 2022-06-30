class LinkmeSurveysController < AuthenticatedController

  def index
    @page_title = 'Linkme Surveys'
    @datatable = Effective::Datatables::LinkmeSurveys.new
  end

  def download_linkme_survey_data
    survey = LinkmeSurvey.find(params[:id])
    link = survey.link.split('=')
    filepath = filepath_for_report(link[1])
    send_file filepath, :type => 'application/csv', :x_sendfile => false
  end

  private 

  def filepath_for_report(report_name)
    filename = "#{report_name}.csv"
    Rails.root.join('private', 'linkme_surveys', filename)
  end
end