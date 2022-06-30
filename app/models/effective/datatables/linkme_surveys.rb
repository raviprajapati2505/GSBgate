module Effective
  module Datatables
    class LinkmeSurveys < Effective::Datatable
      include ActionView::Helpers::TranslationHelper
      datatable do
        col :title
        col :status
        col :user_access
        col :link, sql_column: 'linkme_surveys.link', label: 'Action', search: false, sort: false do |rec|
          btn_link_to(download_linkme_survey_data_path(rec.id), icon: 'download', size: 'small', tooltip: 'Download Survey Data')
        end
      end

      collection do
        LinkmeSurvey
          .select('linkme_surveys.title',
                  'linkme_surveys.id',
                  'linkme_surveys.status',
                  'linkme_surveys.user_access',
                  'linkme_surveys.link')
      end
    end
  end
end