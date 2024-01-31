module Effective
  module Datatables
    class ProjectsCertificationPaths < Effective::Datatable
      include ApplicationHelper
      include ActionView::Helpers::TranslationHelper
      include ScoreCalculator

      def fetch_scores(certification_path)
        scheme_mix = certification_path&.scheme_mixes&.first
        score_all = score_calculation(scheme_mix)
        score_all = final_cm_revised_avg_scores(certification_path, score_all)
        return score_all
      end

      datatable do
        # col :project_id, sql_column: 'projects.id', as: :integer, search: {collection: Proc.new { Project.all.order(:name).map { |project| [project.code + ', ' + project.name, project.id] } }} do |rec|
        #    rec.project_code + ', ' + rec.project_name
        # end
        col :project_code, col_class: 'col-order-0', label: t('models.effective.datatables.projects.lables.project_code'), sql_column: 'projects.code' do |rec|          
          link_to(
            rec.project_code,
            project_path(rec.project_nr)
          )
          # link_to(project_path(rec.project_nr)) do
          #   rec.project_code
          # end
        end
        col :project_name, col_class: 'col-order-1', sql_column: 'projects.name' do |rec|
          link_to(
            rec.project_name,
            project_path(rec.project_nr)
          )
          # link_to(project_path(rec.project_nr)) do
          #   rec.project_name
          # end
        end

        col :project_country, col_class: 'multiple-select col-order-2', sql_column: 'projects.country', visible: false, search: { as: :select, collection: Proc.new { Project.order(:country).pluck(:country).uniq.compact.map { |country| [country, country] } rescue [] } } do |rec|
          rec.project_country
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")

          unless (collection.class == Array || terms_array.include?(""))
            collection.where("projects.country IN (?)", terms_array.uniq)
          else
            collection
          end
        end

        col :project_city, col_class: 'multiple-select col-order-3', sql_column: 'projects.city', visible: false, search: { as: :select, collection: Proc.new { Project.order(:city).pluck(:city).uniq.compact.map { |city| [city, city] } rescue [] } } do |rec|
          rec.project_city
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")

          unless (collection.class == Array || terms_array.include?(""))
            collection.where("projects.city IN (?)", terms_array.uniq)
          else
            collection
          end
        end

        col :project_district, col_class: 'multiple-select col-order-4', sql_column: 'projects.district', visible: false, search: { as: :select, collection: Proc.new { Project.order(:district).pluck(:district).uniq.compact.map { |district| [district, district] } rescue [] } } do |rec|
          rec.project_district
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")

          unless (collection.class == Array || terms_array.include?(""))
            collection.where("projects.district IN (?)", terms_array.uniq)
          else
            collection
          end
        end

        col :project_developer_business_sector, 
          col_class: 'multiple-select', 
          sql_column: 'projects.project_developer_business_sector', 
          label: t('models.effective.datatables.projects.lables.project_developer_business_sector'), 
          search: { 
            as: :select, 
            collection: Proc.new { Project.project_owner_business_sectors.map { |k, v| [k.titleize, v] } } 
            } do |rec|
          rec.project_developer_business_sector&.titleize

        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless (collection.class == Array || terms_array.include?(""))
            collection.where("projects.project_developer_business_sector IN (?)", terms_array)
          else
            collection
          end
        end

        col :project_owner, col_class: 'multiple-select col-order-6', sql_column: 'projects.owner', label: t('models.effective.datatables.projects.lables.owner'), visible: false, search: { as: :select, collection: Proc.new { Project.order(:owner).pluck(:owner).uniq.compact.map { |owner| [owner, owner] } rescue [] } } do |rec|
          rec.project_owner
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")

          unless (collection.class == Array || terms_array.include?(""))
            collection.where("projects.owner IN (?)", terms_array.uniq)
          else
            collection
          end
        end

        col :project_developer, col_class: 'multiple-select col-order-7', sql_column: 'projects.developer', label: t('models.effective.datatables.projects.lables.developer'), visible: false, search: { as: :select, collection: Proc.new { Project.order(:developer).pluck(:developer).uniq.compact.map { |developer| [developer, developer] } rescue [] } } do |rec|
          rec.project_developer
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")

          unless (collection.class == Array || terms_array.include?(""))
            collection.where("projects.developer IN (?)", terms_array.uniq)
          else
            collection
          end
        end

        col :project_construction_year, col_class: 'col-order-9', label: t('models.effective.datatables.projects.lables.construction_year'), sql_column: 'projects.construction_year', as: :integer, visible: false

        col :project_owner_business_sector, 
          col_class: 'multiple-select', 
          sql_column: 'projects.project_owner_business_sector', 
          label: t('models.effective.datatables.projects.lables.project_owner_business_sector'), 
          search: { 
            as: :select, 
            collection: Proc.new { Project.project_owner_business_sectors.map { |k, v| [k.titleize, v] } } 
            } do |rec|
          rec.project_owner_business_sector&.titleize

        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless (collection.class == Array || terms_array.include?(""))
            collection.where("projects.project_owner_business_sector IN (?)", terms_array)
          else
            collection
          end
        end

        col :project_description, col_class: 'col-order-10', sql_column: 'projects.description', visible: false do |rec|       
          rec.project_description&.truncate(300)
        end

        col :project_site_area, col_class: 'col-order-11', label: t('models.effective.datatables.projects.lables.project_site_area'), sql_column: 'projects.project_site_area', as: :integer, visible: false do |rec|
          number_with_delimiter(rec.project_site_area, delimiter: ',')
        end

        col :project_gross_area, col_class: 'col-order-12', label: t('models.effective.datatables.projects.lables.gross_area'), sql_column: 'projects.gross_area', as: :integer, visible: false do |rec|
          number_with_delimiter(rec.project_gross_area, delimiter: ',')
        end

        col :project_buildings_footprint_area, col_class: 'col-order-13', label: t('models.effective.datatables.projects.lables.buildings_footprint_area'), sql_column: 'projects.buildings_footprint_area', as: :integer, visible: false do |rec|
          number_with_delimiter(rec.project_buildings_footprint_area, delimiter: ',')
        end

        col :project_certified_area, col_class: 'col-order-14', sql_column: 'projects.certified_area', as: :integer, visible: false do |rec|
          number_with_delimiter(rec.project_certified_area, delimiter: ',')
        end

        col :project_carpark_area, col_class: 'col-order-15', sql_column: 'projects.carpark_area', as: :integer, visible: false do |rec|
          number_with_delimiter(rec.project_carpark_area, delimiter: ',')
        end

        col :development_type_name, col_class: 'multiple-select col-order-16', sql_column: 'development_types.name', label: t('models.effective.datatables.projects_certification_paths.certification_path_development_type.label'), search: { as: :select, collection: Proc.new { DevelopmentType.select(:name, :display_weight).order(:display_weight).distinct.map { |development_type| [development_type.name, development_type.name] }.uniq } } do |rec|
          case rec.certification_scheme_name
          when 'Parks'
            'Parks'
          when 'Fitout'
            'Single Zone, Fitout'
          else
            rec.development_type_name
          end
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")

          unless (collection.class == Array || terms_array.include?(""))
            results = []

            terms_array.each do |term|
              collection_set = collection
              
              case term
              when 'Parks'
                results_array = collection_set.joins(certification_paths: [scheme_mixes: :scheme]).where("schemes.name = :term AND (projects.certificate_type <> :certificate_type OR development_types.name NOT IN ('Neighborhoods', 'Mixed Use'))", term: term, certificate_type: Certificate.certificate_types[:design_type]).pluck("certification_paths.id")
              when 'Districts'
                results_array = collection_set.joins(certification_paths: [scheme_mixes: :scheme]).where("schemes.name = :term OR development_types.name = :term", term: term).pluck("certification_paths.id")
              when 'Single Zone'
                results_array = collection_set.joins(certification_paths: [scheme_mixes: :scheme]).where("schemes.name = 'Fitout' OR development_types.name = :term", term: term).pluck("certification_paths.id")
              else
                results_array = collection_set.joins(certification_paths: [scheme_mixes: :scheme]).where("development_types.name = :term AND schemes.name <> 'Fitout'", term: term).pluck("certification_paths.id")
              end
            
              results.push(*results_array)
            end
            
            collection.where("certification_paths.id IN (?)", results.uniq)
          else
            collection
          end
        end

        col :building_type_name, col_class: 'multiple-select col-order-17', sql_column: 'building_types.name', label: t('models.effective.datatables.projects_certification_paths.building_types.label'), visible: false, search: { as: :select, collection: Proc.new { BuildingType.visible.order(:name).pluck(:name).uniq.compact.map { |building_type| [building_type, building_type] } rescue [] } } do |rec|
          rec.building_type_name
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless (collection.class == Array || terms_array.include?(""))
            collection.where("building_types.name IN (?)", terms_array)
          else
            collection
          end
        end

        col :project_service_provider, col_class: 'multiple-select col-order-18', sql_column: 'projects.service_provider', label: t('models.effective.datatables.projects.lables.service_provider'), visible: false, search: { as: :select, collection: Proc.new { Project.order(:service_provider).pluck(:service_provider).uniq.compact.map { |service_provider| [service_provider, service_provider] } rescue [] } } do |rec|
          rec.project_service_provider
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless (collection.class == Array || terms_array.include?(""))
            collection.where("projects.service_provider IN (?)", terms_array)
          else
            collection
          end
        end

        col :cgp_project_manager_array, col_class: 'multiple-select col-order-19', label: t('models.effective.datatables.projects_certification_paths.cgp_project_manager_array.label'), visible: false, sql_column: '(%s)' % projects_users_by_type('cgp_project_manager'), search: { as: :select, collection: Proc.new { ProjectsUser.cgp_project_managers.pluck("users.name").uniq.compact.map { |name| [name, name] } rescue [] } } do |rec|
          ERB::Util.html_escape(rec.cgp_project_manager_array).split('|||').sort.join(', <br/>') unless rec.cgp_project_manager_array.nil?
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless (collection.class == Array || terms_array.include?(""))
            collection.where('(%s) ILIKE ANY ( array[:terms_array] )' % projects_users_by_type('cgp_project_manager'), terms_array: terms_array.map! {|val| "%#{val}%" }) rescue collection
          else
            collection
          end
        end

        col :project_team_array, col_class: 'col-order-20', label: t('models.effective.datatables.projects_certification_paths.project_team_array.label'), visible: false, sql_column: '(%s)' % projects_users_by_type('project_team') do |rec|
          ERB::Util.html_escape(rec.project_team_array).split('|||').sort.join(', <br/>') unless rec.project_team_array.nil?
        end

        #col :certification_path_id, sql_column: 'certification_paths.id', as: :integer, label: 'Certificate ID'
        col :certificate_id, col_class: 'multiple-select col-order-21', sql_column: 'certificates.id', label: t('models.effective.datatables.projects_certification_paths.certificate_id.label'), search: { as: :select, collection: Proc.new { Certificate.all.order(:display_weight).map { |certificate| [certificate.only_certification_name, certificate.only_certification_name] }.uniq}, multiple: true } do |rec|
          if rec.certification_path_id.present?
            only_certification_name = Certificate.find_by_name(rec&.certificate_name)&.only_certification_name
            certification_name_datatable_render(rec, only_certification_name)
          end
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless (collection.class == Array || terms_array.include?(""))
            collection.where("certificates.certification_type IN (?)", Certificate.get_certification_types(terms_array))
          else
            collection
          end
        end

        col :certification_assessment_method, col_class: 'multiple-select col-order-22', sql_column: 'certification_paths.id', label: t('models.effective.datatables.projects_certification_paths.assessment_method.label'), search: { as: :select, collection: Proc.new { [["Checklist Assessment", 0]] } } do |rec|
          CertificationPath.find_by(id: rec.certification_path_id)&.assessment_method_title
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          
          unless (collection.class == Array || terms_array.include?("") || terms_array == ["1", "2"])
            collection.joins(certification_paths: :certification_path_method).where("certification_path_methods.assessment_method = (:terms_array)", terms_array: terms_array)
          else
            collection
          end
        end

        col :certificate_version, col_class: 'multiple-select col-order-23', sql_column: 'certificates.id', label: t('models.effective.datatables.projects_certification_paths.certificate_version.label'), search: { as: :select, collection: Proc.new { Certificate.all.order(:display_weight).map { |certificate| [certificate.only_version, certificate.only_version] }.uniq } } do |rec|
          if rec.certification_path_id.present?
            only_certification_version = Certificate.find_by_name(rec&.certificate_name)&.only_version
            link_to(
              only_certification_version,
              project_certification_path_path(rec.project_nr, rec.certification_path_id)
            )
          end
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless (collection.class == Array || terms_array.include?(""))
            collection.where("certificates.gsb_version IN (?)", terms_array)
          else
            collection
          end
        end

        col :certification_scheme_name, col_class: 'multiple-select col-order-24', label: t('models.effective.datatables.projects_certification_paths.certification_scheme_name.label'), sql_column: "ARRAY_TO_STRING(ARRAY(SELECT schemes.name FROM schemes INNER JOIN scheme_mixes ON schemes.id = scheme_mixes.scheme_id WHERE scheme_mixes.certification_path_id = certification_paths.id), '|||')" , search: { as: :select, collection: Proc.new { get_schemes_names } } do |rec|
          development_type_name = rec.development_type_name
          if (rec.design_and_build? || rec.ecoleaf?) && ["Neighborhoods", "Mixed Use"].include?(development_type_name)
            development_type_name
          elsif development_type_name == "Districts"
            "Districts"
          else
            # rec.certification_scheme_name
            ERB::Util.html_escape(rec.certification_scheme_name).split('|||').sort.join('<br/>') unless rec.certification_scheme_name.nil?
          end
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")

          unless (collection.class == Array || terms_array.include?(""))
            results = []

            terms_array.each do |term|
              collection_set = collection

              case term
              when "Mixed Use", "Neighborhoods"
                results_array = collection_set.where("development_types.name = :term AND projects.certificate_type IN (:certificate_type)", term: term, certificate_type: [Certificate.certificate_types[:design_type], Certificate.certificate_types[:ecoleaf_type]]).pluck("certification_paths.id")
              when "Districts"
                results_array = collection_set.joins(certification_paths: [scheme_mixes: :scheme]).where("schemes.name = :term OR development_types.name = :term", term: term).pluck("certification_paths.id")
              else
                results_array = collection_set.joins(certification_paths: [scheme_mixes: :scheme]).where("schemes.name = :term AND (projects.certificate_type <> :certificate_type OR development_types.name NOT IN ('Neighborhoods', 'Mixed Use'))", term: term, certificate_type: Certificate.certificate_types[:design_type]).pluck("certification_paths.id")
              end
              results.push(*results_array)
            end
            
            collection.where("certification_paths.id IN (?)", results.uniq)
          else
            collection
          end
        end

        col :schemes_array, col_class: 'col-order-25', label: t('models.effective.datatables.projects_certification_paths.schemes_array.label'), sql_column: "ARRAY_TO_STRING(ARRAY(SELECT case when scheme_mixes.custom_name is null then schemes.name else schemes.name end from schemes INNER JOIN scheme_mixes ON schemes.id = scheme_mixes.scheme_id WHERE scheme_mixes.certification_path_id = certification_paths.id), '|||')" do |rec|
          unless rec.schemes_array.nil?
            schemes_array = ERB::Util.html_escape(rec.schemes_array).split('|||').sort
            if schemes_array.size > 1
              schemes_array.join('<br/>')
            end
          end
        end

        col :schemes_custom_name_array, col_class: 'col-order-26', label: t('models.effective.datatables.projects_certification_paths.schemes_custom_name_array.label'), visible: false, sql_column: "ARRAY_TO_STRING(ARRAY(SELECT case when scheme_mixes.custom_name is null then ' ' else scheme_mixes.custom_name end from schemes INNER JOIN scheme_mixes ON schemes.id = scheme_mixes.scheme_id WHERE scheme_mixes.certification_path_id = certification_paths.id ORDER BY schemes.name), '|||')" do |rec|
          ERB::Util.html_escape(rec.schemes_custom_name_array).split('|||').join('<br/>') unless rec.schemes_custom_name_array.nil?
        end

        col :certificate_stage, col_class: 'multiple-select col-order-27', sql_column: 'certificates.id', label: t('models.effective.datatables.projects_certification_paths.certificate_stage.label'), search: { as: :select, collection: Proc.new { get_certificate_types_names(current_user) } } do |rec|
          if rec.certification_path_id.present?
            only_certification_stage = CertificationPath.find(rec.certification_path_id).certificate&.name
            link_to(
              only_certification_stage,
              project_certification_path_path(rec.project_nr, rec.certification_path_id)
            )
          end
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          collection_set = collection
          results_array = []
          recent_certificates_ids = []

          unless (collection.class == Array || terms_array.include?(""))
            if (terms_array.include?("Recent Stages"))
              terms_array.delete("Recent Stages")

              recent_certificates_ids = CertificationPath.most_recent&.ids&.uniq
            end

            unless terms_array.blank?
              results_array = collection_set.where("certificates.certification_type IN (?)", Certificate.get_certificate_by_stage(terms_array)).pluck("certification_paths.id")
            end

            all_cert_ids = recent_certificates_ids.push(*results_array).uniq

            collection.where("certification_paths.id IN (?)", all_cert_ids)
          else
            collection
          end
        end

        col :total_achieved_score, as: :decimal, col_class: 'col-order-28', label: t('models.effective.datatables.projects_certification_paths.total_achieved_score.label'), visible: false, sql_column: '(%s)' % ProjectsCertificationPaths.query_score_in_certificate_points(:achieved_score), search: false do |rec|
          if !rec.total_achieved_score.nil?
            score = rec&.total_achieved_score
            certification_path = CertificationPath.find(rec&.certification_path_id)

            if certification_path&.certificate&.design_and_build?
              score = 0 if score < 0
            end

            if certification_path&.construction? && !certification_path&.is_activating?
              score_all = fetch_scores(certification_path)
              score = score_all[:achieved_score_in_certificate_points]
            end

            if rec.certificate_gsb_version == 'v2.1 Issue 1.0' && certification_path&.construction?
              number_to_percentage(score, precision: 1)
            else
              if !score.nil? && score > 3
                3.0
              else
                score.round(2)
              end
            end
          end
        end

        col :certification_path_certification_path_status_id, col_class: 'multiple-select col-order-29', sql_column: 'certification_paths.certification_path_status_id', label: t('models.effective.datatables.projects_certification_paths.certification_path_certification_path_status_id.label'), search: { as: :select, collection: Proc.new { CertificationPathStatus.all.map { |status| status.id == CertificationPathStatus::CERTIFICATE_IN_PROCESS ? ["Certificate In Process/Generated", status.id] : [status.name, status.id]} } }  do |rec|
          submission_status_datatable_render(rec)
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless (collection.class == Array || terms_array.include?(""))
            collection.where("certification_paths.certification_path_status_id IN (?)", terms_array.map!{|term| term.to_i})
          else
            collection
          end
        end

        col :rating, partial: '/certification_paths/rating', col_class: 'col-order-30', partial_as: 'rec', search: false, as: :decimal, label: t('models.effective.datatables.projects_certification_paths.rating.label'), sql_column: '(%s)' % ProjectsCertificationPaths.query_score_in_certificate_points(:achieved_score)

        # Note: internally we use the status id, so sorting is done by id and not the name !
        
        col :certification_path_started_at, col_class: 'date-range-filter col-order-31', sql_column: 'certification_paths.started_at', label: t('models.effective.datatables.projects_certification_paths.certification_path_started_at.label'), as: :datetime, visible: false do |rec|
          rec.certification_path_started_at&.strftime('%e %b - %Y')
        end.search do |collection, term, column, index|

          from_date = term.split(' - ')[0]&.to_datetime
          to_date = term.split(' - ')[1]&.to_datetime

          unless (collection.class == Array)
            collection.where("DATE(certification_paths.started_at) BETWEEN :from_date AND :to_date", from_date: from_date, to_date: to_date)
          else
            collection
          end
        end

        col :certification_path_certified_at, col_class: 'date-range-filter col-order-32', sql_column: 'certification_paths.certified_at', label: t('models.effective.datatables.projects_certification_paths.certification_path_certified_at.label'), as: :datetime, visible: false do |rec|
          rec.certification_path_certified_at&.strftime('%e %b - %Y')
        end.search do |collection, term, column, index|
          from_date = term.split(' - ')[0]&.to_datetime
          to_date = term.split(' - ')[1]&.to_datetime

          unless (collection.class == Array)
            collection.where("DATE(certification_paths.certified_at) BETWEEN :from_date AND :to_date", from_date: from_date, to_date: to_date)
          else
            collection
          end
        end

        col :certification_path_expires_at, col_class: 'date-range-filter col-order-33', sql_column: 'certification_paths.expires_at', label: t('models.effective.datatables.projects_certification_paths.certification_path_expires_at.label'), as: :datetime, visible: false do |rec|
          rec.certification_path_expires_at&.strftime('%e %b, %Y')
        end.search do |collection, term, column, index|
          from_date = term.split(' - ')[0]&.to_datetime
          to_date = term.split(' - ')[1]&.to_datetime

          unless (collection.class == Array)
            collection.where("DATE(certification_paths.expires_at) BETWEEN :from_date AND :to_date", from_date: from_date, to_date: to_date)
          else
            collection
          end
        end

        col :certification_path_updated_at, col_class: 'date-range-filter col-order-34', label: t('models.effective.datatables.projects_certification_paths.certification_path_updated_at.label'), sql_column: 'certification_paths.updated_at', as: :datetime, visible: false do |rec|
          rec.certification_path_updated_at&.strftime('%e %b - %Y')
        end.search do |collection, term, column, index|
          from_date = term.split(' - ')[0]&.to_datetime
          to_date = term.split(' - ')[1]&.to_datetime

          unless (collection.class == Array)
            collection.where("DATE(certification_paths.updated_at) BETWEEN :from_date AND :to_date", from_date: from_date, to_date: to_date)
          else
            collection
          end
        end

        # col :certification_path_status_name, sql_column: 'certification_path_statuses.name', label: 'Certificate Status', search: {as: :select, collection: Proc.new{CertificationPathStatus.all.map{|status| status.name}}}

        col :certification_path_status_is_active, col_class: 'col-order-35', sql_column: 'CASE WHEN certification_path_statuses.id IS NULL THEN false WHEN certification_path_statuses.id = 15 THEN false WHEN certification_path_statuses.id = 16 THEN false WHEN certification_path_statuses.id = 17 THEN false ELSE true END', visible: false, as: :boolean, label: t('models.effective.datatables.projects_certification_paths.certification_path_status_is_active.label')

        col :certification_path_pcr_track, col_class: 'col-order-36', sql_column: 'certification_paths.pcr_track', label: t('models.effective.datatables.projects_certification_paths.certification_path_pcr_track.label'), as: :boolean, visible: false

        col :certification_manager_array, col_class: 'multiple-select col-order-37', label: t('models.effective.datatables.projects_certification_paths.certification_manager_array.label'), visible: false, sql_column: '(%s)' % projects_users_by_type('certification_manager'), search: { as: :select, collection: Proc.new { ProjectsUser.certification_managers.pluck("users.name").uniq.compact.map { |name| [name, name] } rescue [] } } do |rec|
          ERB::Util.html_escape(rec.certification_manager_array).split('|||').sort.join(', <br/>') unless rec.certification_manager_array.nil?
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless (collection.class == Array || terms_array.include?(""))
            collection.where('(%s) ILIKE ANY ( array[:terms_array] )' % projects_users_by_type('certification_manager'), terms_array: terms_array.map! {|val| "%#{val}%" }) rescue collection
          else
            collection
          end
        end

        col :gsb_trust_team_array, col_class: 'col-order-38', label: t('models.effective.datatables.projects_certification_paths.gsb_trust_team_array.label'), visible: false, sql_column: '(%s)' % projects_users_by_type('gsb_trust_team') do |rec|
          ERB::Util.html_escape(rec.gsb_trust_team_array).split('|||').sort.join(', <br/>') unless rec.gsb_trust_team_array.nil?
        end

        col :enterprise_clients_array, col_class: 'multiple-select col-order-39', label: t('models.effective.datatables.projects_certification_paths.enterprise_clients_array.label'), visible: false, sql_column: '(%s)' % projects_users_by_type('enterprise_clients'), search: { as: :select, collection: Proc.new { ProjectsUser.enterprise_clients.pluck("users.name").uniq.compact.map { |name| [name, name] } rescue [] } } do |rec|
          ERB::Util.html_escape(rec.enterprise_clients_array).split('|||').sort.join(', <br/>') unless rec.enterprise_clients_array.nil?
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless (collection.class == Array || terms_array.include?(""))
            collection.where('(%s) ILIKE ANY ( array[:terms_array] )' % projects_users_by_type('enterprise_clients'), terms_array: terms_array.map! {|val| "%#{val}%" }) rescue collection
          else
            collection
          end
        end
      end

      collection do
        projects = Project.datatable_projects_records
        
        if current_user.is_service_provider?
          project_ids = Project.accessible_by(current_ability).pluck(:id)
          projects.where(id: project_ids.uniq)
        else
          projects.accessible_by(current_ability)
        end
      end
    end
  end
end