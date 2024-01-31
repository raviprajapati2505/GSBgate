module Effective
  module Datatables
    class OfflineProjects < Effective::Datatable
      include ApplicationHelper
      include ActionView::Helpers::TranslationHelper

      datatable do
        col :code, 
            label: t('models.effective.datatables.projects.lables.project_code') do |rec| 
              link_to_if(!current_user.is_record_checker?,
                rec.code,
                offline_project_path(rec.id)
              )
        end

        col :name, 
            label: t('models.effective.datatables.offline.project.name') do |rec| 
              link_to_if(!current_user.is_record_checker?,
                rec.name,
                offline_project_path(rec.id)
              )
        end


        col :certified_area, label: t('models.effective.datatables.offline.project.certified_area'), visible: false

        col :plot_area, label: t('models.effective.datatables.offline.project.plot_area'), visible: false

        col :owner, label: t('models.effective.datatables.offline.project.owner')

        col :developer, label: t('models.effective.datatables.offline.project.developer')

        col :project_gross_built_up_area, label: t('models.effective.datatables.offline.project.project_gross_built_up_area')

        col :project_country, label: t('models.effective.datatables.offline.project.project_country')

        col :project_city, label: t('models.effective.datatables.offline.project.project_city')

        col :project_district, label: t('models.effective.datatables.offline.project.project_district')

        col :project_owner_business_sector, label: t('models.effective.datatables.offline.project.project_owner_business_sector')
        col :project_developer_business_sector, label: t('models.effective.datatables.offline.project.project_developer_business_sector')

        col :assessment_type, col_class: 'multiple-select', sql_column: 'offline_projects.assessment_type', label: t('models.effective.datatables.offline.project.assessment_type'), search: { as: :select, collection: Proc.new { Offline::Project.assessment_types.map { |k, v| [k, v] } } } do |rec|
          rec.assessment_type

        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")

          unless (collection.class == Array || terms_array.include?(""))
            collection.where("offline_projects.assessment_type IN (?)", terms_array)
          else
            collection
          end
        end

        col :construction_year, col_class: 'custom-year-picker col-order-8', label: t('models.effective.datatables.offline.project.construction_year'), as: :datetime, visible: false

        col :certificate_type, 
            col_class: 'multiple-select', 
            sql_column: 'offline_projects.certificate_type', 
            label: t('models.effective.datatables.offline.project.certificate_type'), 
            search: { 
              as: :select, 
              collection: Proc.new { Offline::Project.certificate_types.map { |k, v| [k, v] } } 
            } do |rec|
              certification_name_offline_datatable_render(rec.certificate_type)
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")

          unless (collection.class == Array || terms_array.include?(""))
            collection.where("offline_projects.certificate_type IN (?)", terms_array)
          else
            collection
          end
        end

        col :certification_name, 
            col_class: 'multiple-select', 
            sql_column: 'offline_certification_paths.name', 
            label: t('models.effective.datatables.offline.certification_path.name'), 
            search: { 
              as: :select, 
              collection: Certificate.all.order(:display_weight).map { |certificate| [certificate.name, certificate.name.sub(',', '+')] }.uniq 
            } do |rec| 
            unless !rec.certification_id
              link_to_if(!current_user.is_record_checker?,
                rec.certification_name,
                offline_project_certification_path(rec.id, rec.certification_id)
              )
            end
        end.search do |collection, terms, column, index|
          terms_array = terms.split(',').map { |ele| ele.gsub('+', ',') || ele }

          unless (collection.class == Array || terms_array.include?(""))
            collection.where("offline_certification_paths.name IN (?)", terms_array)
          else
            collection
          end
        end

        col :certification_version, 
            col_class: 'multiple-select', 
            sql_column: 'offline_certification_paths.version', 
            label: t('models.effective.datatables.offline.certification_path.version'), 
            search: { 
              as: :select, 
              collection: Proc.new { Offline::CertificationPath.versions.map { |k, v| [k, v] } } 
            } do |rec|
              unless !rec.certification_id
                link_to_if(!current_user.is_record_checker?,
                  Offline::CertificationPath.versions.keys[rec.certification_version],
                  offline_project_certification_path(rec.id, rec.certification_id)
                )
              end

        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")

          unless (collection.class == Array || terms_array.include?(""))
            collection.where("offline_certification_paths.version IN (?)", terms_array)
          else
            collection
          end
        end

        col :certification_development_type, 
            col_class: 'multiple-select', 
            sql_column: 'offline_certification_paths.development_type', 
            label: t('models.effective.datatables.offline.certification_path.development_type'), 
            search: { 
              as: :select, 
              collection: Proc.new { DevelopmentType.select(:name, :display_weight).order(:display_weight).distinct.map { |development_type| [development_type.name, development_type.name] }.uniq } 
            } do |rec|
          rec.certification_development_type

        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless (collection.class == Array || terms_array.include?(""))
            collection.where("offline_certification_paths.development_type IN (?)", terms_array)
          else
            collection
          end
        end

        col :certification_rating, 
            col_class: 'multiple-select',
            sql_column: 'offline_certification_paths.rating', 
            label: t('models.effective.datatables.offline.certification_path.rating'), 
            search: { 
              as: :select, collection: Proc.new { Offline::CertificationPath.ratings.map { |k, v| [k, v] } } 
            } do |rec|
            render partial: "/offline/certification_paths/rating", locals: { ratings: Offline::CertificationPath.ratings.keys[rec.certification_rating || 0], certification_type: rec.certificate_type }
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless (collection.class == Array || terms_array.include?(""))
            collection.where("offline_certification_paths.rating IN (?)", terms_array.map(&:to_i))
          else
            collection
          end
        end

        col :certification_status, 
          col_class: 'multiple-select', 
          sql_column: 'offline_certification_paths.status', 
          label: t('models.effective.datatables.offline.certification_path.status'), 
          search: { 
            as: :select, collection: Proc.new { CertificationPathStatus.all.map { |status| [status.name, status.name] }.uniq } 
          } do |rec|
            submission_status_offline_datatable_render(rec)
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")

          unless (collection.class == Array || terms_array.include?(""))
            collection.where("offline_certification_paths.status IN (?)", terms_array)
          else
            collection
          end
        end

        col :certification_certified_at, 
          col_class: 'custom-year-picker col-order-14', 
          label: t('models.effective.datatables.offline.certification_path.certified_at'), 
          search: { as: :datetime }, 
          visible: false

          col :certification_scheme_name, 
            col_class: 'multiple-select',
            sql_column: '(%s)' % offline_projects_by_scheme_names,
            label: t('models.effective.datatables.offline.certification_path.schemes'),
            search: { 
              as: :select, collection: Proc.new { get_schemes_names } 
            } do |rec|
            unless rec.certification_scheme_name.nil?
              schemes_array = ERB::Util.html_escape(rec.certification_scheme_name).split('|||').sort
              if schemes_array.size > 0
                schemes_array.join('<br/>')
              end
            end 
          end.search do |collection, terms, column, index|
            terms_array = terms.split(",")
            unless (collection.class == Array || terms_array.include?(""))
              collection.where('(%s) ILIKE ANY ( array[:terms_array] )' % offline_projects_by_scheme_names, terms_array: terms_array.map! {|val| "%#{val}%" }) rescue collection
            else
              collection
            end
        end

        col :subschemes, label: t('models.effective.datatables.offline.certification_path.subscheme')

        col :id, 
            sql_column: 'offline_projects.id', 
            label: 'Action', 
            search: false, 
            sort: false do |rec|
          btn_link_to(edit_offline_project_path(rec.id), icon: 'edit', size: 'small', tooltip: 'Edit Project')
        end
      end

      collection do
        Offline::Project.datatable_projects_records
      end
    end
  end
end
