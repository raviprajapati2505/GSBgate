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

      def projects_users_by_type(team_type)
        case team_type
        when 'project_team'
          "ARRAY_TO_STRING(ARRAY(SELECT project_team_users.name FROM users as project_team_users INNER JOIN projects_users as project_team_project_users ON project_team_project_users.user_id = project_team_users.id  WHERE project_team_project_users.role IN (#{ProjectsUser.roles[:project_team_member]}) AND project_team_project_users.project_id = projects.id AND (SELECT CASE WHEN certificates.certification_type IN (#{Certificate.certification_types['construction_certificate']}, #{Certificate.certification_types['operations_certificate']}, #{Certificate.certification_types['construction_certificate_stage1']}, #{Certificate.certification_types['construction_certificate_stage2']}, #{Certificate.certification_types['construction_certificate_stage3']}) THEN project_team_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Other']}) WHEN certificates.certification_type IN (#{Certificate.certification_types['letter_of_conformance']}) THEN project_team_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Letter of Conformance']}) WHEN certificates.certification_type IN (#{Certificate.certification_types['final_design_certificate']}) THEN project_team_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Final Design Certificate']}) ELSE project_team_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Other']}, #{ProjectsUser.certification_team_types['Letter of Conformance']}, #{ProjectsUser.certification_team_types['Final Design Certificate']}) END)), '|||')"
        when 'cgp_project_manager'
          "ARRAY_TO_STRING(ARRAY(SELECT cgp_project_managers.name FROM users as cgp_project_managers INNER JOIN projects_users as cgp_project_managers_project_users ON cgp_project_managers_project_users.user_id = cgp_project_managers.id  WHERE cgp_project_managers_project_users.role IN (#{ProjectsUser.roles[:cgp_project_manager]}) AND cgp_project_managers_project_users.project_id = projects.id AND (SELECT CASE WHEN certificates.certification_type IN (#{Certificate.certification_types['construction_certificate']}, #{Certificate.certification_types['operations_certificate']}, #{Certificate.certification_types['construction_certificate_stage1']}, #{Certificate.certification_types['construction_certificate_stage2']}, #{Certificate.certification_types['construction_certificate_stage3']}) THEN cgp_project_managers_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Other']}) WHEN certificates.certification_type IN (#{Certificate.certification_types['letter_of_conformance']}) THEN cgp_project_managers_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Letter of Conformance']}) WHEN certificates.certification_type IN (#{Certificate.certification_types['final_design_certificate']}) THEN cgp_project_managers_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Final Design Certificate']}) ELSE cgp_project_managers_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Other']}, #{ProjectsUser.certification_team_types['Letter of Conformance']}, #{ProjectsUser.certification_team_types['Final Design Certificate']}) END)), '|||')"
        when 'gsas_trust_team'
          "ARRAY_TO_STRING(ARRAY(SELECT gsas_trust_team_users.name FROM users as gsas_trust_team_users INNER JOIN projects_users as gsas_trust_team_project_users ON gsas_trust_team_project_users.user_id = gsas_trust_team_users.id  WHERE gsas_trust_team_project_users.role IN (#{ProjectsUser.roles[:certifier]}) AND gsas_trust_team_project_users.project_id = projects.id AND (SELECT CASE WHEN certificates.certification_type IN (#{Certificate.certification_types['construction_certificate']}, #{Certificate.certification_types['operations_certificate']}, #{Certificate.certification_types['construction_certificate_stage1']}, #{Certificate.certification_types['construction_certificate_stage2']}, #{Certificate.certification_types['construction_certificate_stage3']}) THEN gsas_trust_team_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Other']}) WHEN certificates.certification_type IN (#{Certificate.certification_types['letter_of_conformance']}) THEN gsas_trust_team_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Letter of Conformance']}) WHEN certificates.certification_type IN (#{Certificate.certification_types['final_design_certificate']}) THEN gsas_trust_team_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Final Design Certificate']}) ELSE gsas_trust_team_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Other']}, #{ProjectsUser.certification_team_types['Letter of Conformance']}, #{ProjectsUser.certification_team_types['Final Design Certificate']}) END)), '|||')"
        when 'certification_manager'
          "ARRAY_TO_STRING(ARRAY(SELECT certification_managers.name FROM users as certification_managers INNER JOIN projects_users as certification_managers_project_users ON certification_managers_project_users.user_id = certification_managers.id  WHERE certification_managers_project_users.role IN (#{ProjectsUser.roles[:certification_manager]}) AND certification_managers_project_users.project_id = projects.id AND (SELECT CASE WHEN certificates.certification_type IN (#{Certificate.certification_types['construction_certificate']}, #{Certificate.certification_types['operations_certificate']}, #{Certificate.certification_types['construction_certificate_stage1']}, #{Certificate.certification_types['construction_certificate_stage2']}, #{Certificate.certification_types['construction_certificate_stage3']}) THEN certification_managers_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Other']}) WHEN certificates.certification_type IN (#{Certificate.certification_types['letter_of_conformance']}) THEN certification_managers_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Letter of Conformance']}) WHEN certificates.certification_type IN (#{Certificate.certification_types['final_design_certificate']}) THEN certification_managers_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Final Design Certificate']}) ELSE certification_managers_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Other']}, #{ProjectsUser.certification_team_types['Letter of Conformance']}, #{ProjectsUser.certification_team_types['Final Design Certificate']}) END)), '|||')"
        when 'enterprise_clients'
          "ARRAY_TO_STRING(ARRAY(SELECT enterprise_client_users.name FROM users as enterprise_client_users INNER JOIN projects_users as enterprise_client_project_users ON enterprise_client_project_users.user_id = enterprise_client_users.id  WHERE enterprise_client_project_users.role IN (#{ProjectsUser.roles[:enterprise_client]}) AND enterprise_client_project_users.project_id = projects.id), '|||')"
        end
      end

      datatable do
        # col :project_id, sql_column: 'projects.id', as: :integer, search: {collection: Proc.new { Project.all.order(:name).map { |project| [project.code + ', ' + project.name, project.id] } }} do |rec|
        #    rec.project_code + ', ' + rec.project_name
        # end
        col :project_code, col_class: 'col-order-0', label: t('models.effective.datatables.projects.lables.project_code'), sql_column: 'projects.code' do |rec|          
          link_to_if(!current_user.record_checker?,
            rec.project_code,
            project_path(rec.project_nr)
          )
          # link_to(project_path(rec.project_nr)) do
          #   rec.project_code
          # end
        end
        col :project_name, col_class: 'col-order-1', sql_column: 'projects.name' do |rec|
          link_to_if(!current_user.record_checker?,
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

        col :project_address, col_class: 'col-order-5', sql_column: 'projects.address', visible: false do |rec|
          rec.project_address&.truncate(50)
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

        col :project_construction_year, col_class: 'col-order-8', sql_column: 'projects.construction_year', as: :integer, visible: false

        col :project_estimated_project_cost, col_class: 'col-order-9', label: t('models.effective.datatables.projects.lables.estimated_project_cost'), sql_column: 'projects.estimated_project_cost', as: :string, visible: false do |rec|
          number_with_delimiter(rec.project_estimated_project_cost, delimiter: ',')
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
          when 'Interiors'
            'Single Zone, Interiors'
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
                results_array = collection_set.joins(certification_paths: [scheme_mixes: :scheme]).where("schemes.name = 'Interiors' OR development_types.name = :term", term: term).pluck("certification_paths.id")
              else
                results_array = collection_set.joins(certification_paths: [scheme_mixes: :scheme]).where("development_types.name = :term AND schemes.name <> 'Interiors'", term: term).pluck("certification_paths.id")
              end
            
              results.push(*results_array)
            end
            
            collection.where("certification_paths.id IN (?)", results.uniq)
          else
            collection
          end
        end

        col :building_type_name, col_class: 'multiple-select col-order-17', sql_column: 'building_types.name', label: t('models.effective.datatables.projects_certification_paths.building_types.label'), visible: false, search: { as: :select, collection: Proc.new { BuildingType.visible.order(:name).pluck(:name).uniq.map { |building_type| [building_type, building_type] } rescue [] } } do |rec|
          rec.building_type_name
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless (collection.class == Array || terms_array.include?(""))
            collection.where("building_types.name IN (?)", terms_array)
          else
            collection
          end
        end

        col :project_service_provider, col_class: 'multiple-select col-order-18', sql_column: 'projects.service_provider', label: t('models.effective.datatables.projects.lables.service_provider'), visible: false, search: { as: :select, collection: Proc.new { Project.order(:service_provider).pluck(:service_provider).uniq.map { |service_provider| [service_provider, service_provider] } rescue [] } } do |rec|
          rec.project_service_provider
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless (collection.class == Array || terms_array.include?(""))
            collection.where("projects.service_provider IN (?)", terms_array)
          else
            collection
          end
        end

        col :cgp_project_manager_array, col_class: 'multiple-select col-order-19', label: t('models.effective.datatables.projects_certification_paths.cgp_project_manager_array.label'), visible: false, sql_column: '(%s)' % projects_users_by_type('cgp_project_manager'), search: { as: :select, collection: Proc.new { ProjectsUser.cgp_project_managers.pluck("users.name").uniq.map { |name| [name, name] } rescue [] } } do |rec|
          ERB::Util.html_escape(rec.cgp_project_manager_array).split('|||').sort.join(', <br/>') unless rec.cgp_project_manager_array.nil?
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless (collection.class == Array || terms_array.include?(""))
            collection.where('(%s) IN (?)' % projects_users_by_type('cgp_project_manager'), terms_array)
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
            link_to_if(!current_user.record_checker?,
              only_certification_name,
              project_certification_path_path(rec.project_nr, rec.certification_path_id)
            )
          end
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless (collection.class == Array || terms_array.include?(""))
            collection.where("certificates.certification_type IN (?)", Certificate.get_certification_types(terms_array))
          else
            collection
          end
        end

        col :certification_path_id, col_class: 'multiple-select col-order-22', sql_column: 'certification_paths.id', label: t('models.effective.datatables.projects_certification_paths.assessment_method.label'), search: { as: :select, collection: Proc.new { [["Star Rating Based Certificate", 1], ["Checklist Based Certificate", 2]] } } do |rec|
          certification_assessment_type_title(CertificationPathMethod.find_by(certification_path_id: rec.certification_path_id)&.assessment_method)
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          
          unless (collection.class == Array || terms_array.include?("") || terms_array == ["1", "2"])
            if terms_array == ["1"]
              checklist_certifications = collection.joins(certification_paths: :certification_path_method).where("certification_path_methods.assessment_method = 2")
              collection.where("projects.certificate_type <> 3 OR certification_paths.id NOT IN (?)", checklist_certifications&.group("certification_path_methods.certification_path_id")&.pluck("certification_path_methods.certification_path_id"))
            elsif terms_array == ["2"]
              collection.joins(certification_paths: :certification_path_method).where("certification_path_methods.assessment_method = 2")
            end
          else
            collection
          end
        end

        col :certificate_version, col_class: 'multiple-select col-order-23', sql_column: 'certificates.id', label: t('models.effective.datatables.projects_certification_paths.certificate_version.label'), search: { as: :select, collection: Proc.new { Certificate.all.order(:display_weight).map { |certificate| [certificate.only_version, certificate.only_version] }.uniq } } do |rec|
          if rec.certification_path_id.present?
            only_certification_version = Certificate.find_by_name(rec&.certificate_name)&.only_version
            link_to_if(!current_user.record_checker?,
              only_certification_version,
              project_certification_path_path(rec.project_nr, rec.certification_path_id)
            )
          end
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless (collection.class == Array || terms_array.include?(""))
            collection.where("certificates.gsas_version IN (?)", terms_array)
          else
            collection
          end
        end

        col :certification_scheme_name, col_class: 'multiple-select col-order-24', label: t('models.effective.datatables.projects_certification_paths.certification_scheme_name.label'), sql_column: "ARRAY_TO_STRING(ARRAY(SELECT schemes.name FROM schemes INNER JOIN scheme_mixes ON schemes.id = scheme_mixes.scheme_id WHERE scheme_mixes.certification_path_id = certification_paths.id), '|||')" , search: { as: :select, collection: Proc.new { get_schemes_names } } do |rec|
          development_type_name = rec.development_type_name
          if rec.design_and_build? && ["Neighborhoods", "Mixed Use"].include?(development_type_name)
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
                results_array = collection_set.where("development_types.name = :term AND projects.certificate_type = :certificate_type", term: term, certificate_type: Certificate.certificate_types[:design_type]).pluck("certification_paths.id")
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
            only_certification_stage = CertificationPath.find(rec.certification_path_id).certificate&.stage_title
            link_to_if(!current_user.record_checker?,
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
            if (terms_array.include?("Recent Certificates"))
              terms_array.delete("Recent Certificates")

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

            if rec.certificate_gsas_version == 'v2.1 Issue 1.0' && certification_path&.construction?
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
          if rec.certification_path_status_name == "Certificate In Process"
            CertificationPath.find(rec&.certification_path_id)&.status
          else
            rec.certification_path_status_name
          end
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
        
        col :certification_path_started_at, col_class: 'date-range-filter col-order-31', sql_column: 'certification_paths.started_at', label: t('models.effective.datatables.projects_certification_paths.certification_path_started_at.label'), as: :datetime, visible: true do |rec|
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

        col :certification_path_updated_at, col_class: 'date-range-filter col-order-33', label: t('models.effective.datatables.projects_certification_paths.certification_path_updated_at.label'), sql_column: 'certification_paths.updated_at', as: :datetime, visible: false do |rec|
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

        col :certification_path_status_is_active, col_class: 'col-order-34', sql_column: 'CASE WHEN certification_path_statuses.id IS NULL THEN false WHEN certification_path_statuses.id = 15 THEN false WHEN certification_path_statuses.id = 16 THEN false WHEN certification_path_statuses.id = 17 THEN false ELSE true END', visible: false, as: :boolean, label: t('models.effective.datatables.projects_certification_paths.certification_path_status_is_active.label')

        col :certification_path_pcr_track, col_class: 'col-order-35', sql_column: 'certification_paths.pcr_track', label: t('models.effective.datatables.projects_certification_paths.certification_path_pcr_track.label'), as: :boolean, visible: false

        col :certification_manager_array, col_class: 'multiple-select col-order-36', label: t('models.effective.datatables.projects_certification_paths.certification_manager_array.label'), visible: false, sql_column: '(%s)' % projects_users_by_type('certification_manager'), search: { as: :select, collection: Proc.new { ProjectsUser.certification_managers.pluck("users.name").uniq.map { |name| [name, name] } rescue [] } } do |rec|
          ERB::Util.html_escape(rec.certification_manager_array).split('|||').sort.join(', <br/>') unless rec.certification_manager_array.nil?
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless (collection.class == Array || terms_array.include?(""))
            collection.where('(%s) IN (?)' % projects_users_by_type('certification_manager'), terms_array)
          else
            collection
          end
        end

        col :gsas_trust_team_array, col_class: 'col-order-37', label: t('models.effective.datatables.projects_certification_paths.gsas_trust_team_array.label'), visible: false, sql_column: '(%s)' % projects_users_by_type('gsas_trust_team') do |rec|
          ERB::Util.html_escape(rec.gsas_trust_team_array).split('|||').sort.join(', <br/>') unless rec.gsas_trust_team_array.nil?
        end

        col :enterprise_clients_array, col_class: 'multiple-select col-order-38', label: t('models.effective.datatables.projects_certification_paths.enterprise_clients_array.label'), visible: false, sql_column: '(%s)' % projects_users_by_type('enterprise_clients'), search: { as: :select, collection: Proc.new { ProjectsUser.enterprise_clients.pluck("users.name").uniq.map { |name| [name, name] } rescue [] } } do |rec|
          ERB::Util.html_escape(rec.enterprise_clients_array).split('|||').sort.join(', <br/>') unless rec.enterprise_clients_array.nil?
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless (collection.class == Array || terms_array.include?(""))
            collection.where('(%s) IN (?)' % projects_users_by_type('enterprise_clients'), terms_array)
          else
            collection
          end
        end
      end

      collection do
        Project
          .joins('LEFT OUTER JOIN projects_users ON projects_users.project_id = projects.id')
          .joins('LEFT OUTER JOIN certification_paths ON certification_paths.project_id = projects.id')
          .joins('LEFT JOIN certificates ON certification_paths.certificate_id = certificates.id')
          .joins('LEFT JOIN certification_path_statuses ON certification_paths.certification_path_status_id = certification_path_statuses.id')
          .joins('LEFT JOIN development_types ON certification_paths.development_type_id = development_types.id')
          .joins('LEFT JOIN building_types ON projects.building_type_id = building_types.id')
          .group('projects.id')
          .group('projects.owner')
          .group('projects.developer')
          .group('certification_paths.id')
          .group('certificates.id')
          .group('certification_path_statuses.id')
          .group('development_types.id')
          .group('building_types.id')
          .select('projects.id as project_nr')
          .select('projects.code as project_code')
          .select('projects.name as project_name')
          .select('projects.construction_year as project_construction_year')
          .select('projects.estimated_project_cost as project_estimated_project_cost')
          .select('projects.country as project_country')
          .select('projects.city as project_city')
          .select('projects.district as project_district')
          .select('projects.address as project_address')
          .select('projects.description as project_description')
          .select('projects.gross_area as project_gross_area')
          .select('projects.certified_area as project_certified_area')
          .select('projects.carpark_area as project_carpark_area')
          .select('projects.project_site_area as project_site_area')
          .select('projects.buildings_footprint_area as project_buildings_footprint_area')
          .select('projects.owner as project_owner')
          .select('projects.developer as project_developer')
          .select('projects.service_provider as project_service_provider')
          .select('certification_paths.id as certification_path_id')
          .select('certification_paths.updated_at as certification_path_updated_at')
          .select('certification_paths.certificate_id as certificate_id')
          .select('certification_paths.certification_path_status_id as certification_path_certification_path_status_id')
          .select('certification_paths.pcr_track as certification_path_pcr_track')
          .select("ARRAY_TO_STRING(ARRAY(SELECT schemes.name FROM schemes INNER JOIN scheme_mixes ON schemes.id = scheme_mixes.scheme_id WHERE scheme_mixes.certification_path_id = certification_paths.id), '|||') AS certification_scheme_name")
          .select('development_types.name as development_type_name')
          .select('building_types.name as building_type_name')
          .select('certification_paths.started_at as certification_path_started_at')
          .select('certification_paths.certified_at as certification_path_certified_at')
          .select("certificates.name as certificate_name")
          .select("certificates.certificate_type as certificate_type")
          .select('certificates.gsas_version as certificate_gsas_version')
          .select('certification_path_statuses.name as certification_path_status_name')
          .select('CASE WHEN certification_path_statuses.id IS NULL THEN false WHEN certification_path_statuses.id = 15 THEN false WHEN certification_path_statuses.id = 16 THEN false WHEN certification_path_statuses.id = 17 THEN false ELSE true END as certification_path_status_is_active')
          .select("ARRAY_TO_STRING(ARRAY(SELECT case when scheme_mixes.custom_name is null then schemes.name else schemes.name end from schemes INNER JOIN scheme_mixes ON schemes.id = scheme_mixes.scheme_id WHERE scheme_mixes.certification_path_id = certification_paths.id), '|||') AS schemes_array")
          .select("ARRAY_TO_STRING(ARRAY(SELECT case when scheme_mixes.custom_name is null then ' ' else scheme_mixes.custom_name end from schemes INNER JOIN scheme_mixes ON schemes.id = scheme_mixes.scheme_id WHERE scheme_mixes.certification_path_id = certification_paths.id ORDER BY schemes.name), '|||') AS schemes_custom_name_array")
          .select('(%s) AS project_team_array' % projects_users_by_type('project_team'))
          .select('(%s) AS cgp_project_manager_array' % projects_users_by_type('cgp_project_manager'))
          .select('(%s) AS gsas_trust_team_array' % projects_users_by_type('gsas_trust_team'))
          .select('(%s) AS certification_manager_array' % projects_users_by_type('certification_manager'))
          .select('(%s) AS enterprise_clients_array' % projects_users_by_type('enterprise_clients'))
          .select('(%s) AS total_achieved_score' % ProjectsCertificationPaths.query_score_in_certificate_points(:achieved_score))
          .order("projects.code")
          .order("certificates.display_weight")
          .accessible_by(current_ability)
      end
    end
  end
end