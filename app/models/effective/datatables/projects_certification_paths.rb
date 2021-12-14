module Effective
  module Datatables
    class ProjectsCertificationPaths < Effective::Datatable
      include ApplicationHelper
      include ActionView::Helpers::TranslationHelper
      include ScoreCalculator

      def fetch_scores(certification_path)
        scheme_mix = certification_path&.scheme_mixes&.first
        score_all = score_calculation(scheme_mix)
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
        end
      end

      datatable do
        # col :project_id, sql_column: 'projects.id', as: :integer, search: {collection: Proc.new { Project.all.order(:name).map { |project| [project.code + ', ' + project.name, project.id] } }} do |rec|
        #    rec.project_code + ', ' + rec.project_name
        # end
        col :project_code, label: t('models.effective.datatables.projects.lables.project_code'), sql_column: 'projects.code' do |rec|          
          link_to_if(!current_user.record_checker?,
            rec.project_code,
            project_path(rec.project_nr)
          )
          # link_to(project_path(rec.project_nr)) do
          #   rec.project_code
          # end
        end
        col :project_name, sql_column: 'projects.name' do |rec|
          link_to_if(!current_user.record_checker?,
            rec.project_name,
            project_path(rec.project_nr)
          )
          # link_to(project_path(rec.project_nr)) do
          #   rec.project_name
          # end
        end
        col :project_update, label: t('models.effective.datatables.projects.lables.updated_at'), sql_column: 'projects.updated_at', visible: false do |rec|
          link_to_if(!current_user.record_checker?,
            rec.project_updated_at.strftime('%e %b, %Y'),
            project_path(rec.project_nr)
          )
          # link_to(project_path(rec.project_nr)) do
          #   localize(rec.project_updated_at.in_time_zone)
          # end
        end
        col :project_construction_year, sql_column: 'projects.construction_year', as: :integer, visible: false
        col :project_estimated_project_cost, label: t('models.effective.datatables.projects.lables.estimated_project_cost'), sql_column: 'projects.estimated_project_cost', as: :string, visible: false
        col :project_country, sql_column: 'projects.country', visible: false
        col :project_city, sql_column: 'projects.city', visible: false
        col :project_district, sql_column: 'projects.district', visible: false
        col :project_address, sql_column: 'projects.address', visible: false
        col :project_description, sql_column: 'projects.description', visible: false do |rec|       
          rec.project_description&.truncate(200)
        end
       
        col :project_gross_area, label: t('models.effective.datatables.projects.lables.gross_area'), sql_column: 'projects.gross_area', as: :integer, visible: false
        col :project_certified_area, sql_column: 'projects.certified_area', as: :integer, visible: false
        col :project_carpark_area, sql_column: 'projects.carpark_area', as: :integer, visible: false
        col :project_site_area, label: t('models.effective.datatables.projects.lables.project_site_area'), sql_column: 'projects.project_site_area', as: :integer, visible: false
        col :project_buildings_footprint_area, label: t('models.effective.datatables.projects.lables.buildings_footprint_area'), sql_column: 'projects.buildings_footprint_area', as: :integer, visible: false
        col :project_created_at, label: t('models.effective.datatables.projects.lables.created_at'), sql_column: 'projects.created_at', as: :datetime, visible: false, search: { as: :select, collection: Proc.new { Project.all.order(created_at: :desc).map { |p| [p.created_at&.strftime('%e %b, %Y'), p.created_at&.to_date] }.uniq } } do |rec|
          rec.project_created_at&.strftime('%e %b, %Y')
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless collection.class == Array
            collection.where("DATE(projects.created_at) IN (?)", terms_array.map!{|term| term.to_date})
          end
        end

        col :project_owner, sql_column: 'projects.owner', label: t('models.effective.datatables.projects.lables.owner'), visible: false
        col :project_developer, sql_column: 'projects.developer', label: t('models.effective.datatables.projects.lables.developer'), visible: false

        col :development_type_name, sql_column: 'development_types.name', label: t('models.effective.datatables.projects_certification_paths.certification_path_development_type.label'), search: { as: :select, collection: Proc.new { DevelopmentType.select(:name, :display_weight).order(:display_weight).distinct.map { |development_type| [development_type.name, development_type.name] } } } do |rec|
          rec.development_type_name
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless collection.class == Array
            collection.where("development_types.name IN (?)", terms_array)
          end
        end

        #col :certification_path_id, sql_column: 'certification_paths.id', as: :integer, label: 'Certificate ID'
        col :certificate_id, sql_column: 'certificates.id', label: t('models.effective.datatables.projects_certification_paths.certificate_id.label'), search: { as: :select, collection: Proc.new { Certificate.all.order(:display_weight).map { |certificate| [certificate.only_certification_name, certificate.only_certification_name] }.uniq}, multiple: true } do |rec|
          if rec.certification_path_id.present?
            only_certification_name = Certificate.find_by_name(rec&.certificate_name)&.only_certification_name
            link_to_if(!current_user.record_checker?,
              only_certification_name,
              project_certification_path_path(rec.project_nr, rec.certification_path_id)
            )
          end
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless collection.class == Array
            collection.where("certificates.certification_type IN (?)", Certificate.get_certification_types(terms_array))
          end
        end

        col :certificate_version, sql_column: 'certificates.id', label: t('models.effective.datatables.projects_certification_paths.certificate_version.label'), search: { as: :select, collection: Proc.new { Certificate.all.order(:display_weight).map { |certificate| [certificate.only_version, certificate.only_version] }.uniq } } do |rec|
          if rec.certification_path_id.present?
            only_certification_version = Certificate.find_by_name(rec&.certificate_name)&.only_version
            link_to_if(!current_user.record_checker?,
              only_certification_version,
              project_certification_path_path(rec.project_nr, rec.certification_path_id)
            )
          end
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless collection.class == Array
            collection.where("certificates.gsas_version IN (?)", terms_array)
          end
        end

        col :building_type_group_name, sql_column: 'building_type_groups.name', label: t('models.effective.datatables.projects_certification_paths.building_type_groups.label'), search: { as: :select, collection: Proc.new { BuildingTypeGroup.visible.select(:name).order(:name).distinct.map { |building_type_group| [building_type_group.name, building_type_group.name] } } } do |rec|
          rec.building_type_group_name
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless collection.class == Array
            collection.where("building_type_groups.name IN (?)", terms_array)
          end
        end

        col :schemes_array, label: t('models.effective.datatables.projects_certification_paths.schemes_array.label'), sql_column: "ARRAY_TO_STRING(ARRAY(SELECT case when scheme_mixes.custom_name is null then concat(schemes.name, ' ', schemes.gsas_version) else CONCAT(schemes.name, ' (', scheme_mixes.custom_name, ') ', schemes.gsas_version) end from schemes INNER JOIN scheme_mixes ON schemes.id = scheme_mixes.scheme_id WHERE scheme_mixes.certification_path_id = certification_paths.id), '|||')" do |rec|
          ERB::Util.html_escape(rec.schemes_array).split('|||').sort.join('<br/>') unless rec.schemes_array.nil?
        end

        col :certificate_stage, sql_column: 'certificates.id', label: t('models.effective.datatables.projects_certification_paths.certificate_stage.label'), search: { as: :select, collection: Proc.new { Certificate.all.order(:display_weight).map { |certificate| [certificate.stage_title, certificate.stage_title&.delete(",")] }.uniq } } do |rec|
          if rec.certification_path_id.present?
            only_certification_stage = CertificationPath.find(rec.certification_path_id).certificate&.stage_title
            link_to_if(!current_user.record_checker?,
              only_certification_stage,
              project_certification_path_path(rec.project_nr, rec.certification_path_id)
            )
          end
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless collection.class == Array
            collection.where("certificates.certification_type IN (?)", Certificate.get_certificate_by_stage(terms_array))
          end
        end

        col :certification_path_pcr_track, sql_column: 'certification_paths.pcr_track', label: t('models.effective.datatables.projects_certification_paths.certification_path_pcr_track.label'), as: :boolean, visible: false

        # Note: internally we use the status id, so sorting is done by id and not the name !
        col :certification_path_certification_path_status_id, sql_column: 'certification_paths.certification_path_status_id', label: t('models.effective.datatables.projects_certification_paths.certification_path_certification_path_status_id.label'), search: { as: :select, collection: Proc.new { CertificationPathStatus.all.map { |status| [status.name, status.id] } } }  do |rec|
          rec.certification_path_status_name
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless collection.class == Array
            collection.where("certification_paths.certification_path_status_id IN (?)", terms_array.map!{|term| term.to_i})
          end
        end

        col :certification_path_appealed, sql_column: 'certification_paths.appealed', label: t('models.effective.datatables.projects_certification_paths.certification_path_appealed.label'), as: :boolean, visible: false

        col :certification_path_created_at, sql_column: 'certification_paths.created_at', label: t('models.effective.datatables.projects_certification_paths.certification_path_created_at.label'), as: :datetime, visible: false, search: { as: :select, collection: Proc.new { CertificationPath.all.order(created_at: :desc).map { |c| [c.created_at&.strftime('%e %b, %Y'), c.created_at&.to_date] }.uniq } } do |rec|
          rec.certification_path_created_at&.strftime('%e %b, %Y')
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless collection.class == Array
            collection.where("DATE(certification_paths.created_at) IN (?)", terms_array.map!{|term| term.to_date})
          end
        end

        col :certification_path_started_at, sql_column: 'certification_paths.started_at', label: t('models.effective.datatables.projects_certification_paths.certification_path_started_at.label'), as: :datetime, visible: false, search: { as: :select, collection: Proc.new { CertificationPath.all.order(started_at: :desc).map { |c| [c.started_at&.strftime('%e %b, %Y'), c.started_at&.to_date] }.uniq } } do |rec|
          rec.certification_path_started_at&.strftime('%e %b, %Y')
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless collection.class == Array
            collection.where("DATE(certification_paths.started_at) IN (?)", terms_array.map!{|term| term.to_date})
          end
        end
        
        col :certification_path_certified_at, sql_column: 'certification_paths.certified_at', label: t('models.effective.datatables.projects_certification_paths.certification_path_certified_at.label'), as: :datetime, visible: false, search: { as: :select, collection: Proc.new { CertificationPath.all.order(certified_at: :desc).map { |c| [c.certified_at&.strftime('%e %b, %Y'), c.certified_at&.to_date] }.uniq } } do |rec|
          rec.certification_path_certified_at&.strftime('%e %b, %Y')
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless collection.class == Array
            collection.where("DATE(certification_paths.certified_at) IN (?)", terms_array.map!{|term| term.to_date})
          end
        end

        col :certification_path_expires_at, sql_column: 'certification_paths.expires_at', label: t('models.effective.datatables.projects_certification_paths.certification_path_expires_at.label'), as: :datetime, visible: false, search: { as: :select, collection: Proc.new { CertificationPath.all.order(expires_at: :desc).map { |c| [c.expires_at&.strftime('%e %b, %Y'), c.expires_at&.to_date] }.uniq } } do |rec|
          rec.certification_path_expires_at&.strftime('%e %b, %Y')
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless collection.class == Array
            collection.where("DATE(certification_paths.expires_at) IN (?)", terms_array.map!{|term| term.to_date})
          end
        end

        # col :certification_path_status_name, sql_column: 'certification_path_statuses.name', label: 'Certificate Status', search: {as: :select, collection: Proc.new{CertificationPathStatus.all.map{|status| status.name}}}
        col :certification_path_status_is_active, sql_column: 'CASE WHEN certification_path_statuses.id IS NULL THEN false WHEN certification_path_statuses.id = 15 THEN false WHEN certification_path_statuses.id = 16 THEN false ELSE true END', visible: false, as: :boolean, label: t('models.effective.datatables.projects_certification_paths.certification_path_status_is_active.label')

        col :rating, partial: '/certification_paths/rating', partial_as: 'rec', search: false, as: :decimal, label: t('models.effective.datatables.projects_certification_paths.rating.label'), sql_column: '(%s)' % ProjectsCertificationPaths.query_score_in_certificate_points(:achieved_score)

        col :total_achieved_score, as: :decimal, label: t('models.effective.datatables.projects_certification_paths.total_achieved_score.label'), visible: false, sql_column: '(%s)' % ProjectsCertificationPaths.query_score_in_certificate_points(:achieved_score), search: false do |rec|
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
              
            # if rec.certificate_gsas_version == 'v2.1 Issue 1.0' && rec.certificate_type == Certificate.certificate_types[:construction_type]
            #   number_to_percentage(rec.total_achieved_score, precision: 1)
            # else
            #   score = rec&.total_achieved_score

            #   certification_path = CertificationPath.find(rec&.certification_path_id)
            #   if certification_path&.certificate&.construction_2019?
            #     score_all = fetch_scores(certification_path)
            #     score = score_all[:achieved_score_in_certificate_points]
            #   end

            #   if certification_path&.certificate&.design_and_build?
            #     score = 0 if score < 0
            #   end

            #   if !score.nil? && score > 3
            #     3.0
            #   else
            #     score.round(2)
            #   end
            # end
          end
        end

        col :total_submitted_score, as: :decimal, label: t('models.effective.datatables.projects_certification_paths.total_submitted_score.label'), visible: false, sql_column: '(%s)' % ProjectsCertificationPaths.query_score_in_certificate_points(:submitted_score), search: false do |rec|
          if !rec.total_submitted_score.nil?
            score = rec&.total_submitted_score
            certification_path = CertificationPath.find(rec&.certification_path_id)

            if certification_path&.certificate&.design_and_build?
              score = 0 if score < 0
            end

            if certification_path&.construction? && !certification_path&.is_activating?
              score_all = fetch_scores(certification_path)
              score = score_all[:submitted_score_in_certificate_points]
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

        col :total_targeted_score, as: :decimal, label: t('models.effective.datatables.projects_certification_paths.total_targeted_score.label'), visible: false, sql_column: '(%s)' % ProjectsCertificationPaths.query_score_in_certificate_points(:targeted_score), search: false do |rec|
          if !rec.total_targeted_score.nil?

            score = rec&.total_targeted_score
            certification_path = CertificationPath.find(rec&.certification_path_id)

            if certification_path&.certificate&.design_and_build?
              score = 0 if score < 0
            end

            if certification_path&.construction? && !certification_path&.is_activating?
              score_all = fetch_scores(certification_path)
              score = score_all[:targeted_score_in_certificate_points]
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


        col :project_service_provider, sql_column: 'projects.service_provider', label: t('models.effective.datatables.projects.lables.service_provider'), visible: false

        col :project_team_array, label: t('models.effective.datatables.projects_certification_paths.project_team_array.label'), visible: false, sql_column: '(%s)' % projects_users_by_type('project_team') do |rec|
          ERB::Util.html_escape(rec.project_team_array).split('|||').sort.join(', <br/>') unless rec.project_team_array.nil?
        end
        col :cgp_project_manager_array, label: t('models.effective.datatables.projects_certification_paths.cgp_project_manager_array.label'), visible: false, sql_column: '(%s)' % projects_users_by_type('cgp_project_manager') do |rec|
          ERB::Util.html_escape(rec.cgp_project_manager_array).split('|||').sort.join(', <br/>') unless rec.cgp_project_manager_array.nil?
        end
        col :gsas_trust_team_array, label: t('models.effective.datatables.projects_certification_paths.gsas_trust_team_array.label'), visible: false, sql_column: '(%s)' % projects_users_by_type('gsas_trust_team') do |rec|
          ERB::Util.html_escape(rec.gsas_trust_team_array).split('|||').sort.join(', <br/>') unless rec.gsas_trust_team_array.nil?
        end
        col :certification_manager_array, label: t('models.effective.datatables.projects_certification_paths.certification_manager_array.label'), visible: false, sql_column: '(%s)' % projects_users_by_type('certification_manager') do |rec|
          ERB::Util.html_escape(rec.certification_manager_array).split('|||').sort.join(', <br/>') unless rec.certification_manager_array.nil?
        end
        col :enterprise_clients_array, label: t('models.effective.datatables.projects_certification_paths.enterprise_clients_array.label'), visible: false, sql_column: "ARRAY_TO_STRING(ARRAY(SELECT enterprise_client_users.name FROM users as enterprise_client_users INNER JOIN projects_users as enterprise_client_project_users ON enterprise_client_project_users.user_id = enterprise_client_users.id  WHERE enterprise_client_project_users.role IN (#{ProjectsUser.roles[:enterprise_client]}) AND enterprise_client_project_users.project_id = projects.id), '|||')" do |rec|
          ERB::Util.html_escape(rec.enterprise_clients_array).split('|||').sort.join(', <br/>') unless rec.enterprise_clients_array.nil?
        end

        col :building_type_name, sql_column: 'building_types.name', label: t('models.effective.datatables.projects_certification_paths.building_types.label'), visible: false, search: { as: :select, collection: Proc.new { BuildingType.visible.select(:name).order(:name).distinct.map { |building_type| [building_type.name, building_type.name] } } } do |rec|
          rec.building_type_name
        end.search do |collection, terms, column, index|
          terms_array = terms.split(",")
          unless collection.class == Array
            collection.where("building_types.name IN (?)", terms_array)
          end
        end
      end

      collection do
        Project
          .joins('LEFT OUTER JOIN projects_users ON projects_users.project_id = projects.id')
          .joins('LEFT OUTER JOIN certification_paths ON certification_paths.project_id = projects.id')
          .joins('LEFT JOIN certificates ON certificates.id = certification_paths.certificate_id')
          .joins('LEFT JOIN certification_path_statuses ON certification_path_statuses.id = certification_paths.certification_path_status_id')
          .joins('LEFT JOIN development_types ON development_types.id = certification_paths.development_type_id')
          .joins('LEFT JOIN building_type_groups ON building_type_groups.id = projects.building_type_group_id')
          .joins('LEFT JOIN building_types ON building_types.id = projects.building_type_id')
          .group('projects.id')
          .group('projects.owner')
          .group('projects.developer')
          .group('certification_paths.id')
          .group('certificates.id')
          .group('certification_path_statuses.id')
          .group('development_types.id')
          .group('building_type_groups.id')
          .group('building_types.id')
          .select('projects.id as project_nr')
          .select('projects.code as project_code')
          .select('projects.name as project_name')
          .select('projects.updated_at as project_updated_at')
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
          .select('projects.created_at as project_created_at')
          .select('projects.owner as project_owner')
          .select('projects.developer as project_developer')
          .select('projects.service_provider as project_service_provider')
          .select('certification_paths.id as certification_path_id')
          .select('certification_paths.certificate_id as certificate_id')
          .select('certification_paths.certification_path_status_id as certification_path_certification_path_status_id')
          .select('certification_paths.pcr_track as certification_path_pcr_track')
          .select('development_types.id as development_type_id')
          .select('development_types.name as development_type_name')
          .select('building_type_groups.id as building_type_group_id')
          .select('building_type_groups.name as building_type_group_name')
          .select('building_types.id as building_type_id')
          .select('building_types.name as building_type_name')
          .select('certification_paths.appealed as certification_path_appealed')
          .select('certification_paths.created_at as certification_path_created_at')
          .select('certification_paths.started_at as certification_path_started_at')
          .select('certification_paths.certified_at as certification_path_certified_at')
          .select('certification_paths.expires_at as certification_path_expires_at')
          .select("certificates.name as certificate_name")
          .select("certificates.certificate_type as certificate_type")
          .select('certificates.gsas_version as certificate_gsas_version')
          .select('certification_path_statuses.name as certification_path_status_name')
          .select('CASE WHEN certification_path_statuses.id IS NULL THEN false WHEN certification_path_statuses.id = 15 THEN false WHEN certification_path_statuses.id = 16 THEN false ELSE true END as certification_path_status_is_active')
          .select("ARRAY_TO_STRING(ARRAY(SELECT case when scheme_mixes.custom_name is null then concat(schemes.name, ' ', schemes.gsas_version) else CONCAT(schemes.name, ' (', scheme_mixes.custom_name, ') ', schemes.gsas_version) end from schemes INNER JOIN scheme_mixes ON schemes.id = scheme_mixes.scheme_id WHERE scheme_mixes.certification_path_id = certification_paths.id), '|||') AS schemes_array")
          .select('(%s) AS project_team_array' % projects_users_by_type('project_team'))
          .select('(%s) AS cgp_project_manager_array' % projects_users_by_type('cgp_project_manager'))
          .select('(%s) AS gsas_trust_team_array' % projects_users_by_type('gsas_trust_team'))
          .select('(%s) AS certification_manager_array' % projects_users_by_type('certification_manager'))
          .select("ARRAY_TO_STRING(ARRAY(SELECT enterprise_client_users.name FROM users as enterprise_client_users INNER JOIN projects_users as enterprise_client_project_users ON enterprise_client_project_users.user_id = enterprise_client_users.id  WHERE enterprise_client_project_users.role IN (#{ProjectsUser.roles[:enterprise_client]}) AND enterprise_client_project_users.project_id = projects.id), '|||') AS enterprise_clients_array")
          .select('(%s) AS total_achieved_score' % ProjectsCertificationPaths.query_score_in_certificate_points(:achieved_score))
          .select('(%s) AS total_submitted_score' % ProjectsCertificationPaths.query_score_in_certificate_points(:submitted_score))
          .select('(%s) AS total_targeted_score' % ProjectsCertificationPaths.query_score_in_certificate_points(:targeted_score))
          .accessible_by(current_ability)
      end
    end
  end
end