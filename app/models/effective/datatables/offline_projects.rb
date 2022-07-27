module Effective
  module Datatables
    class OfflineProjects < Effective::Datatable
      include ApplicationHelper
      include ActionView::Helpers::TranslationHelper

      def offline_projects_by_scheme_names
        "ARRAY_TO_STRING(
          ARRAY(
            SELECT offline_scheme_mixes.name
            FROM offline_scheme_mixes
            WHERE offline_scheme_mixes.offline_certification_path_id = offline_certification_paths.id
          ), 
          '|||'
        )"
      end

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

        col :certified_area, label: t('models.effective.datatables.offline.project.certified_area'), visible: false

        col :plot_area, label: t('models.effective.datatables.offline.project.plot_area'), visible: false

        col :owner, label: t('models.effective.datatables.offline.project.owner')

        col :developer, label: t('models.effective.datatables.offline.project.developer')

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

        col :certification_name, 
            col_class: 'multiple-select', 
            sql_column: 'offline_certification_paths.name', 
            label: t('models.effective.datatables.offline.certification_path.name'), 
            search: { 
              as: :select, 
              collection: Certificate.all.order(:display_weight).map { |certificate| [certificate.stage_title, certificate.stage_title.sub(',', '+')] }.uniq 
            } do |rec| 
            link_to_if(!current_user.is_record_checker?,
              rec.certification_name,
              offline_project_certification_path(rec.id, rec.certification_id)
            )
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
            link_to_if(!current_user.is_record_checker?,
              Offline::CertificationPath.versions.keys[rec.certification_version],
              offline_project_certification_path(rec.id, rec.certification_id)
            )

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
              as: :select, collection: Proc.new { Offline::CertificationPath.ratings.map { |k, v| [k.titleize, v] } } 
            } do |rec|
            render partial: "/offline/certification_paths/rating.html.erb", locals: { ratings: rec.certification_rating + 1, certification_type: rec.certificate_type }
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

        col :id, 
            sql_column: 'offline_projects.id', 
            label: 'Action', 
            search: false, 
            sort: false do |rec|
          btn_link_to(edit_offline_project_path(rec.id), icon: 'edit', size: 'small', tooltip: 'Edit Project')
        end
      end

      collection do
        Offline::Project
          .joins('LEFT OUTER JOIN offline_certification_paths ON offline_certification_paths.offline_project_id = offline_projects.id')
          .group('offline_projects.id')
          .group('offline_certification_paths.id')
          .select('offline_projects.code',
                  'offline_projects.id',
                  'offline_projects.name',
                  'offline_projects.certificate_type',
                  'offline_projects.certified_area',
                  'offline_projects.plot_area',
                  'offline_projects.owner',
                  'offline_projects.developer',
                  'offline_projects.description',
                  'offline_projects.assessment_type',
                  'offline_projects.construction_year',
                  'offline_certification_paths.id as certification_id',
                  'offline_certification_paths.name as certification_name',
                  'offline_certification_paths.version as certification_version',
                  'offline_certification_paths.development_type as certification_development_type',
                  'offline_certification_paths.status as certification_status',
                  'offline_certification_paths.certified_at as certification_certified_at',
                  'offline_certification_paths.rating as certification_rating')
          .select('(%s) AS certification_scheme_name' % offline_projects_by_scheme_names)
      end
    end
  end
end
