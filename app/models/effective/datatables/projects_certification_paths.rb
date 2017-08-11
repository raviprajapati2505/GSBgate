module Effective
  module Datatables
    class ProjectsCertificationPaths < Effective::Datatable
      include ActionView::Helpers::TranslationHelper
      include ScoreCalculator

      attr_accessor :current_ability

      datatable do
        # table_column 'project_id', column: 'projects.id', type: :integer, filter: {values: Proc.new { Project.all.order(:name).map { |project| [project.code + ', ' + project.name, project.id] } }} do |rec|
        #    rec.project_code + ', ' + rec.project_name
        # end
        table_column 'project_code', column: 'projects.code' do |rec|
          link_to(project_path(rec.project_nr)) do
            rec.project_code
          end
        end
        table_column 'project_name', column: 'projects.name' do |rec|
          link_to(project_path(rec.project_nr)) do
            rec.project_name
          end
        end
        table_column 'project_construction_year', column: 'projects.construction_year', type: :integer, visible: false
        table_column 'project_country', column: 'projects.country', visible: false
        table_column 'project_location', column: 'projects.location', visible: false
        table_column 'project_address', column: 'projects.address', visible: false
        table_column 'project_description', column: 'projects.description', visible: false
        table_column 'project_gross_area', column: 'projects.gross_area', type: :integer, visible: false
        table_column 'project_certified_area', column: 'projects.certified_area', type: :integer, visible: false
        table_column 'project_carpark_area', column: 'projects.carpark_area', type: :integer, visible: false
        table_column 'project_site_area', column: 'projects.project_site_area', type: :integer, visible: false
        table_column 'project_created_at', column: 'projects.created_at', type: :datetime, visible: false, filter: {type: :select, values: Proc.new { Project.pluck_date_field_by_year_month_day(:created_at, :desc) }} do |rec|
          localize(rec.project_created_at.in_time_zone) unless rec.project_created_at.nil?
        end

        table_column 'project_owner', column: 'projects.owner', label: 'Project Owner', visible: false
        table_column 'project_developer', column: 'projects.developer', label: 'Project Developer', visible: false

        #table_column 'certification_path_id', column: 'certification_paths.id', type: :integer, label: 'Certificate ID'
        table_column 'certificate_id', column: 'certificates.id', label: t('models.effective.datatables.projects_certification_paths.certificate_id.label'), filter: {type: :select, values: Proc.new { Certificate.all.order(:display_weight).map { |certificate| [certificate.full_name, certificate.id] } }} do |rec|
          if rec.certification_path_id.present?
            link_to(project_certification_path_path(rec.project_nr, rec.certification_path_id)) do
              rec.certificate_name
            end
          end
        end

        table_column 'certification_path_pcr_track', column: 'certification_paths.pcr_track', label: t('models.effective.datatables.projects_certification_paths.certification_path_pcr_track.label'), type: :boolean, visible: false
        table_column 'development_type_name', column: 'development_types.name', label: t('models.effective.datatables.projects_certification_paths.certification_path_development_type.label'), visible: false, filter: {type: :select, values: Proc.new { DevelopmentType.select(:name, :display_weight).order(:display_weight).distinct.map{|development_type| [development_type.name, development_type.name]} }} do |rec|
          rec.development_type_name
        end

        table_column 'certification_path_appealed', column: 'certification_paths.appealed', label: t('models.effective.datatables.projects_certification_paths.certification_path_appealed.label'), type: :boolean, visible: false
        table_column 'certification_path_created_at', column: 'certification_paths.created_at', label: t('models.effective.datatables.projects_certification_paths.certification_path_created_at.label'), type: :datetime, visible: false, filter: {type: :select, values: Proc.new { CertificationPath.pluck_date_field_by_year_month_day(:created_at, :desc) }} do |rec|
          localize(rec.certification_path_created_at.in_time_zone) unless rec.certification_path_created_at.nil?
        end
        table_column 'certification_path_started_at', column: 'certification_paths.started_at', label: t('models.effective.datatables.projects_certification_paths.certification_path_started_at.label'), type: :datetime, visible: false, filter: {type: :select, values: Proc.new { CertificationPath.pluck_date_field_by_year_month_day(:started_at, :desc) }} do |rec|
          localize(rec.certification_path_started_at.in_time_zone) unless rec.certification_path_started_at.nil?
        end
        table_column 'certification_path_certified_at', column: 'certification_paths.certified_at', label: t('models.effective.datatables.projects_certification_paths.certification_path_certified_at.label'), type: :datetime, visible: false, filter: {type: :select, values: Proc.new { CertificationPath.pluck_date_field_by_year_month_day(:certified_at, :desc) }} do |rec|
          localize(rec.certification_path_certified_at.in_time_zone) unless rec.certification_path_certified_at.nil?
        end
        table_column 'certification_path_duration', column: 'certification_paths.duration', label: t('models.effective.datatables.projects_certification_paths.certification_path_duration.label'), type: :integer, visible: false
        # Note: internally we use the status id, so sorting is done by id and not the name !
        table_column 'certification_path_certification_path_status_id', column: 'certification_paths.certification_path_status_id', label: t('models.effective.datatables.projects_certification_paths.certification_path_certification_path_status_id.label'), filter: {type: :select, values: Proc.new { CertificationPathStatus.all.map { |status| [status.name, status.id] } }} do |rec|
          rec.certification_path_status_name
        end
        # table_column 'certification_path_status_name', column: 'certification_path_statuses.name', label: 'Certificate Status', filter: {type: :select, values: Proc.new{CertificationPathStatus.all.map{|status| status.name}}}
        table_column 'certification_path_status_is_active', column: 'CASE WHEN certification_path_statuses.id IS NULL THEN false WHEN certification_path_statuses.id = 15 THEN false WHEN certification_path_statuses.id = 16 THEN false ELSE true END', type: :boolean, label: t('models.effective.datatables.projects_certification_paths.certification_path_status_is_active.label')

        table_column 'stars', :partial => '/certification_paths/stars', :partial_local => 'rec', filter: false, type: :decimal, label: t('models.effective.datatables.projects_certification_paths.stars.label'), column: '(%s)' % ProjectsCertificationPaths.query_score_in_certificate_points(:achieved_score)
        table_column 'total_achieved_score', type: :decimal, label: t('models.effective.datatables.projects_certification_paths.total_achieved_score.label'), column: '(%s)' % ProjectsCertificationPaths.query_score_in_certificate_points(:achieved_score), filter: false
        table_column 'total_submitted_score', type: :decimal, label: t('models.effective.datatables.projects_certification_paths.total_submitted_score.label'), column: '(%s)' % ProjectsCertificationPaths.query_score_in_certificate_points(:submitted_score), filter: false
        table_column 'total_targeted_score', type: :decimal, label: t('models.effective.datatables.projects_certification_paths.total_targeted_score.label'), column: '(%s)' % ProjectsCertificationPaths.query_score_in_certificate_points(:targeted_score), filter: false

        table_column 'schemes_array', label: t('models.effective.datatables.projects_certification_paths.schemes_array.label'), column: "ARRAY_TO_STRING(ARRAY(SELECT case when scheme_mixes.custom_name is null then concat(schemes.name, ' ', schemes.gsas_version) else CONCAT(schemes.name, ' (', scheme_mixes.custom_name, ') ', schemes.gsas_version) end from schemes INNER JOIN scheme_mixes ON schemes.id = scheme_mixes.scheme_id WHERE scheme_mixes.certification_path_id = certification_paths.id), '|||')" do |rec|
          ERB::Util.html_escape(rec.schemes_array).split('|||').sort.join('<br/>') unless rec.schemes_array.nil?
        end
        table_column 'project_team_array', label: t('models.effective.datatables.projects_certification_paths.project_team_array.label'), visible: false, column: "ARRAY_TO_STRING(ARRAY(SELECT project_team_users.name FROM users as project_team_users INNER JOIN projects_users as project_team_project_users ON project_team_project_users.user_id = project_team_users.id  WHERE project_team_project_users.role IN (#{ProjectsUser.roles[:cgp_project_manager]},#{ProjectsUser.roles[:project_team_member]}) AND project_team_project_users.project_id = projects.id), '|||')" do |rec|
          ERB::Util.html_escape(rec.project_team_array).split('|||').sort.join('<br/>') unless rec.project_team_array.nil?
        end
        table_column 'cgp_project_manager_array', label: t('models.effective.datatables.projects_certification_paths.cgp_project_manager_array.label'), visible: false, column: "ARRAY_TO_STRING(ARRAY(SELECT cgp_project_managers.name FROM users as cgp_project_managers INNER JOIN projects_users as cgp_project_managers_project_users ON cgp_project_managers_project_users.user_id = cgp_project_managers.id  WHERE cgp_project_managers_project_users.role IN (#{ProjectsUser.roles[:cgp_project_manager]}) AND cgp_project_managers_project_users.project_id = projects.id), '|||')" do |rec|
          ERB::Util.html_escape(rec.cgp_project_manager_array).split('|||').sort.join('<br/>') unless rec.cgp_project_manager_array.nil?
        end
        table_column 'gsas_trust_team_array', label: t('models.effective.datatables.projects_certification_paths.gsas_trust_team_array.label'), visible: false, column: "ARRAY_TO_STRING(ARRAY(SELECT gsas_trust_team_users.name FROM users as gsas_trust_team_users INNER JOIN projects_users as gsas_trust_team_project_users ON gsas_trust_team_project_users.user_id = gsas_trust_team_users.id  WHERE gsas_trust_team_project_users.role IN (#{ProjectsUser.roles[:certification_manager]},#{ProjectsUser.roles[:certifier]}) AND gsas_trust_team_project_users.project_id = projects.id), '|||')" do |rec|
          ERB::Util.html_escape(rec.gsas_trust_team_array).split('|||').sort.join('<br/>') unless rec.gsas_trust_team_array.nil?
        end
        table_column 'certification_manager_array', label: t('models.effective.datatables.projects_certification_paths.certification_manager_array.label'), visible: false, column: "ARRAY_TO_STRING(ARRAY(SELECT certification_managers.name FROM users as certification_managers INNER JOIN projects_users as certification_managers_project_users ON certification_managers_project_users.user_id = certification_managers.id  WHERE certification_managers_project_users.role IN (#{ProjectsUser.roles[:certification_manager]}) AND certification_managers_project_users.project_id = projects.id), '|||')" do |rec|
          ERB::Util.html_escape(rec.certification_manager_array).split('|||').sort.join('<br/>') unless rec.certification_manager_array.nil?
        end
        table_column 'enterprise_clients_array', label: t('models.effective.datatables.projects_certification_paths.enterprise_clients_array.label'), visible: false, column: "ARRAY_TO_STRING(ARRAY(SELECT enterprise_client_users.name FROM users as enterprise_client_users INNER JOIN projects_users as enterprise_client_project_users ON enterprise_client_project_users.user_id = enterprise_client_users.id  WHERE enterprise_client_project_users.role IN (#{ProjectsUser.roles[:enterprise_client]}) AND enterprise_client_project_users.project_id = projects.id), '|||')" do |rec|
          ERB::Util.html_escape(rec.enterprise_clients_array).split('|||').sort.join('<br/>') unless rec.enterprise_clients_array.nil?
        end
      end

      def collection
        coll = Project
                   .joins('LEFT OUTER JOIN projects_users ON projects_users.project_id = projects.id')
                   .joins('LEFT OUTER JOIN certification_paths ON certification_paths.project_id = projects.id')
                   .joins('LEFT JOIN certificates ON certificates.id = certification_paths.certificate_id')
                   .joins('LEFT JOIN certification_path_statuses ON certification_path_statuses.id = certification_paths.certification_path_status_id')
                   .joins('LEFT JOIN development_types ON development_types.id = certification_paths.development_type_id')
                   .group('projects.id')
                   .group('projects.owner')
                   .group('projects.developer')
                   .group('certification_paths.id')
                   .group('certificates.id')
                   .group('certification_path_statuses.id')
                   .group('development_types.id')
                   .select('projects.id as project_nr')
                   .select('projects.code as project_code')
                   .select('projects.name as project_name')
                   .select('projects.construction_year as project_construction_year')
                   .select('projects.country as project_country')
                   .select('projects.location as project_location')
                   .select('projects.address as project_address')
                   .select('projects.description as project_description')
                   .select('projects.gross_area as project_gross_area')
                   .select('projects.certified_area as project_certified_area')
                   .select('projects.carpark_area as project_carpark_area')
                   .select('projects.project_site_area as project_site_area')
                   .select('projects.created_at as project_created_at')
                   .select('projects.owner as project_owner')
                   .select('projects.developer as project_developer')
                   .select('certification_paths.id as certification_path_id')
                   .select('certification_paths.certificate_id as certificate_id')
                   .select('certification_paths.certification_path_status_id as certification_path_certification_path_status_id')
                   .select('certification_paths.pcr_track as certification_path_pcr_track')
                   .select('development_types.id as development_type_id')
                   .select('development_types.name as development_type_name')
                   .select('certification_paths.appealed as certification_path_appealed')
                   .select('certification_paths.created_at as certification_path_created_at')
                   .select('certification_paths.started_at as certification_path_started_at')
                   .select('certification_paths.certified_at as certification_path_certified_at')
                   .select('certification_paths.duration as certification_path_duration')
                   .select("CONCAT(certificates.name, ' ', certificates.gsas_version) as certificate_name")
                   .select('certification_path_statuses.name as certification_path_status_name')
                   .select('CASE WHEN certification_path_statuses.id IS NULL THEN false WHEN certification_path_statuses.id = 15 THEN false WHEN certification_path_statuses.id = 16 THEN false ELSE true END as certification_path_status_is_active')
                   .select("ARRAY_TO_STRING(ARRAY(SELECT case when scheme_mixes.custom_name is null then concat(schemes.name, ' ', schemes.gsas_version) else CONCAT(schemes.name, ' (', scheme_mixes.custom_name, ') ', schemes.gsas_version) end from schemes INNER JOIN scheme_mixes ON schemes.id = scheme_mixes.scheme_id WHERE scheme_mixes.certification_path_id = certification_paths.id), '|||') AS schemes_array")
                   .select("ARRAY_TO_STRING(ARRAY(SELECT project_team_users.name FROM users as project_team_users INNER JOIN projects_users as project_team_project_users ON project_team_project_users.user_id = project_team_users.id  WHERE project_team_project_users.role IN (#{ProjectsUser.roles[:cgp_project_manager]},#{ProjectsUser.roles[:project_team_member]}) AND project_team_project_users.project_id = projects.id), '|||') AS project_team_array")
                   .select("ARRAY_TO_STRING(ARRAY(SELECT cgp_project_managers.name FROM users as cgp_project_managers INNER JOIN projects_users as cgp_project_managers_project_users ON cgp_project_managers_project_users.user_id = cgp_project_managers.id  WHERE cgp_project_managers_project_users.role IN (#{ProjectsUser.roles[:cgp_project_manager]}) AND cgp_project_managers_project_users.project_id = projects.id), '|||') AS cgp_project_manager_array")
                   .select("ARRAY_TO_STRING(ARRAY(SELECT gsas_trust_team_users.name FROM users as gsas_trust_team_users INNER JOIN projects_users as gsas_trust_team_project_users ON gsas_trust_team_project_users.user_id = gsas_trust_team_users.id  WHERE gsas_trust_team_project_users.role IN (#{ProjectsUser.roles[:certification_manager]},#{ProjectsUser.roles[:certifier]}) AND gsas_trust_team_project_users.project_id = projects.id), '|||') AS gsas_trust_team_array")
                   .select("ARRAY_TO_STRING(ARRAY(SELECT certification_managers.name FROM users as certification_managers INNER JOIN projects_users as certification_managers_project_users ON certification_managers_project_users.user_id = certification_managers.id  WHERE certification_managers_project_users.role IN (#{ProjectsUser.roles[:certification_manager]}) AND certification_managers_project_users.project_id = projects.id), '|||') AS certification_manager_array")
                   .select("ARRAY_TO_STRING(ARRAY(SELECT enterprise_client_users.name FROM users as enterprise_client_users INNER JOIN projects_users as enterprise_client_project_users ON enterprise_client_project_users.user_id = enterprise_client_users.id  WHERE enterprise_client_project_users.role IN (#{ProjectsUser.roles[:enterprise_client]}) AND enterprise_client_project_users.project_id = projects.id), '|||') AS enterprise_clients_array")
                   .select('(%s) AS total_achieved_score' % ProjectsCertificationPaths.query_score_in_certificate_points(:achieved_score))
                   .select('(%s) AS total_submitted_score' % ProjectsCertificationPaths.query_score_in_certificate_points(:submitted_score))
                   .select('(%s) AS total_targeted_score' % ProjectsCertificationPaths.query_score_in_certificate_points(:targeted_score))
        # Ensure we always have an ability, so we will not show unauthorized data
        if current_ability.nil?
          # Rails.logger.debug "NO ABILITY"
          return coll.none
        else
          # use cancan ability to limit the authorized projects
          # Rails.logger.debug "ABILITY OK"
          return coll.accessible_by(current_ability)
        end
      end

    end
  end
end