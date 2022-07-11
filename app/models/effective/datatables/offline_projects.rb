module Effective
  module Datatables
    class OfflineProjects < Effective::Datatable
      include ActionView::Helpers::TranslationHelper
      datatable do
        col :code, label: t('models.effective.datatables.projects.lables.project_code') do |rec| 
          link_to_if(!current_user.record_checker?,
            rec.code,
            offline_project_path(rec.id)
          )
        end
        col :name, label: t('models.effective.datatables.offline.project.name')
        col :certificate_type, label: t('models.effective.datatables.offline.project.certificate_type')
        col :certified_area, label: t('models.effective.datatables.offline.project.site_area')
        col :site_area, label: t('models.effective.datatables.offline.project.certified_area')
        col :developer, label: t('models.effective.datatables.offline.project.developer')
        col :construction_year, label: t('models.effective.datatables.offline.project.construction_year')
        col :id, sql_column: 'offline_projects.id', label: 'Action', search: false, sort: false do |rec|
          btn_link_to(edit_offline_project_path(rec.id), icon: 'edit', size: 'small', tooltip: 'Edit Project')
        end
      end

      collection do
        Offline::Project
          .select('offline_projects.code',
                  'offline_projects.name',
                  'offline_projects.certificate_type',
                  'offline_projects.certified_area',
                  'offline_projects.site_area',
                  'offline_projects.developer',
                  'offline_projects.description',
                  'offline_projects.construction_year',
                  'offline_projects.id')
      end
    end
  end
end