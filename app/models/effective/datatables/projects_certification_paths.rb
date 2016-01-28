module Effective
  module Datatables
    class ProjectsCertificationPaths < Effective::Datatable
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
        table_column 'project_created_at', column: 'projects.created_at', type: :datetime, visible: false, filter: {type: :select, values: Proc.new { Project.pluck_date_field_by_year_month_day(:created_at, :desc) }}

        table_column 'owner_email', column: 'owner.email', label: 'Project Owner Email', visible: false

        #table_column 'certification_path_id', column: 'certification_paths.id', type: :integer, label: 'Certificate ID'
        table_column 'certificate_id', column: 'certificates.id', label: 'Certificate Name', filter: {type: :select, values: Proc.new { Certificate.all.order(:display_weight).map { |certificate| [certificate.full_name, certificate.id] } }} do |rec|
          if rec.certification_path_id.present?
            link_to(project_certification_path_path(rec.project_nr, rec.certification_path_id)) do
              rec.certificate_name
            end
          end
        end

        table_column 'certification_path_pcr_track', column: 'certification_paths.pcr_track', label: 'Certificate PCR Track', type: :boolean, visible: false
        table_column 'certification_path_pcr_track_allowed', column: 'certification_paths.pcr_track_allowed', label: 'Certificate PCR Track Allowed', type: :boolean, visible: false
        table_column 'certification_path_development_type', column: 'certification_paths.development_type', type: :integer, label: 'Certificate Development Type', visible: false, filter: {type: :select, values: Proc.new { CertificationPath.development_types.map { |k| [k[0].humanize, k[1]] } }} do |rec|
          CertificationPath.development_types.keys[rec.certification_path_development_type].humanize unless rec.certification_path_development_type.nil?
        end
        table_column 'certification_path_appealed', column: 'certification_paths.appealed', label: 'Certificate Appealed', type: :boolean, visible: false
        table_column 'certification_path_created_at', column: 'certification_paths.created_at', label: 'Certificate Created At', type: :datetime, visible: false, filter: {type: :select, values: Proc.new { CertificationPath.pluck_date_field_by_year_month_day(:created_at, :desc) }}
        table_column 'certification_path_started_at', column: 'certification_paths.started_at', label: 'Certificate Started At', type: :datetime, visible: false, filter: {type: :select, values: Proc.new { CertificationPath.pluck_date_field_by_year_month_day(:started_at, :desc) }}
        table_column 'certification_path_certified_at', column: 'certification_paths.certified_at', label: 'Certificate Certified At', type: :datetime, visible: false, filter: {type: :select, values: Proc.new { CertificationPath.pluck_date_field_by_year_month_day(:certified_at, :desc) }}
        table_column 'certification_path_duration', column: 'certification_paths.duration', label: 'Certificate Duration', type: :integer, visible: false
        # Note: internally we use the status id, so sorting is done by id and not the name !
        table_column 'certification_path_certification_path_status_id', column: 'certification_paths.certification_path_status_id', label: 'Certificate Status', filter: {type: :select, values: Proc.new { CertificationPathStatus.all.map { |status| [status.name, status.id] } }} do |rec|
          rec.certification_path_status_name
        end
        # table_column 'certification_path_status_name', column: 'certification_path_statuses.name', label: 'Certificate Status', filter: {type: :select, values: Proc.new{CertificationPathStatus.all.map{|status| status.name}}}
        table_column 'certification_path_status_is_active', column: 'CASE WHEN certification_path_statuses.id IS NULL THEN false WHEN certification_path_statuses.id = 15 THEN false WHEN certification_path_statuses.id = 16 THEN false ELSE true END', type: :boolean, label: 'Certificate Active'

        table_column 'stars', :partial => '/certification_paths/stars', :partial_local => 'rec', filter: false, type: :decimal, label: 'Certificate Star Rating', column: '(%s)' % ProjectsCertificationPaths.query_score_in_certificate_points(:achieved_score)
        table_column 'total_achieved_score', type: :decimal, label: 'Certificate Achieved Score', column: '(%s)' % ProjectsCertificationPaths.query_score_in_certificate_points(:achieved_score)
        table_column 'total_submitted_score', type: :decimal, label: 'Certificate Submitted Score', column: '(%s)' % ProjectsCertificationPaths.query_score_in_certificate_points(:submitted_score)
        table_column 'total_targeted_score', type: :decimal, label: 'Certificate Targeted Score', column: '(%s)' % ProjectsCertificationPaths.query_score_in_certificate_points(:targeted_score)

        table_column 'schemes_array', label: 'Certificate Typologies', column: "ARRAY_TO_STRING(ARRAY(SELECT CONCAT(schemes.name, ' (', scheme_mixes.name, ') ', schemes.gsas_version) from schemes INNER JOIN scheme_mixes ON schemes.id = scheme_mixes.scheme_id WHERE scheme_mixes.certification_path_id = certification_paths.id), '|||')" do |rec|
          rec.schemes_array.split('|||').sort.join('<br/>').html_safe unless rec.schemes_array.nil?
        end
        table_column 'assessors_array', label: 'Project Team', visible: false, column: "ARRAY_TO_STRING(ARRAY(SELECT assessor_users.email FROM users as assessor_users INNER JOIN projects_users as assessor_project_users ON assessor_project_users.user_id = assessor_users.id  WHERE assessor_project_users.role IN (0,1) AND assessor_project_users.project_id = projects.id), '|||')" do |rec|
          rec.assessors_array.split('|||').sort.join('<br/>').html_safe unless rec.assessors_array.nil?
        end
        table_column 'certifiers_array', label: 'Certifier Team', visible: false, column: "ARRAY_TO_STRING(ARRAY(SELECT certifier_users.email FROM users as certifier_users INNER JOIN projects_users as certifier_project_users ON certifier_project_users.user_id = certifier_users.id  WHERE certifier_project_users.role IN (3,4) AND certifier_project_users.project_id = projects.id), '|||')" do |rec|
          rec.certifiers_array.split('|||').sort.join('<br/>').html_safe unless rec.certifiers_array.nil?
        end
        table_column 'enterprise_clients_array', label: 'Enterprise Clients', visible: false, column: "ARRAY_TO_STRING(ARRAY(SELECT enterprise_client_users.email FROM users as enterprise_client_users INNER JOIN projects_users as enterprise_client_project_users ON enterprise_client_project_users.user_id = enterprise_client_users.id  WHERE enterprise_client_project_users.role IN (2) AND enterprise_client_project_users.project_id = projects.id), '|||')" do |rec|
          rec.enterprise_clients_array.split('|||').sort.join('<br/>').html_safe unless rec.enterprise_clients_array.nil?
        end
      end

      def collection
        coll = Project
                   .joins('INNER JOIN users as owner ON owner.id = projects.owner_id')
                   .joins('LEFT OUTER JOIN projects_users ON projects_users.project_id = projects.id')
                   .joins('LEFT OUTER JOIN certification_paths ON certification_paths.project_id = projects.id')
                   .joins('LEFT JOIN certificates ON certificates.id = certification_paths.certificate_id')
                   .joins('LEFT JOIN certification_path_statuses ON certification_path_statuses.id = certification_paths.certification_path_status_id')
                   .group('projects.id')
                   .group('owner.id')
                   .group('certification_paths.id')
                   .group('certificates.id')
                   .group('certification_path_statuses.id')
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
                   .select('projects.owner_id as project_owner_id')
                   .select('owner.email as owner_email')
                   .select('certification_paths.id as certification_path_id')
                   .select('certification_paths.certificate_id as certificate_id')
                   .select('certification_paths.certification_path_status_id as certification_path_certification_path_status_id')
                   .select('certification_paths.pcr_track as certification_path_pcr_track')
                   .select('certification_paths.pcr_track_allowed as certification_path_pcr_track_allowed')
                   .select('certification_paths.development_type as certification_path_development_type')
                   .select('certification_paths.appealed as certification_path_appealed')
                   .select('certification_paths.created_at as certification_path_created_at')
                   .select('certification_paths.started_at as certification_path_started_at')
                   .select('certification_paths.certified_at as certification_path_certified_at')
                   .select('certification_paths.duration as certification_path_duration')
                   .select("CONCAT(certificates.name, ' ', certificates.gsas_version) as certificate_name")
                   .select('certification_path_statuses.name as certification_path_status_name')
                   .select('CASE WHEN certification_path_statuses.id IS NULL THEN false WHEN certification_path_statuses.id = 15 THEN false WHEN certification_path_statuses.id = 16 THEN false ELSE true END as certification_path_status_is_active')
                   .select("ARRAY_TO_STRING(ARRAY(SELECT CONCAT(schemes.name, ' (', scheme_mixes.name, ') ', schemes.gsas_version) from schemes INNER JOIN scheme_mixes ON schemes.id = scheme_mixes.scheme_id WHERE scheme_mixes.certification_path_id = certification_paths.id), '|||') AS schemes_array")
                   .select("ARRAY_TO_STRING(ARRAY(SELECT assessor_users.email FROM users as assessor_users INNER JOIN projects_users as assessor_project_users ON assessor_project_users.user_id = assessor_users.id  WHERE assessor_project_users.role IN (0,1) AND assessor_project_users.project_id = projects.id), '|||') AS assessors_array")
                   .select("ARRAY_TO_STRING(ARRAY(SELECT certifier_users.email FROM users as certifier_users INNER JOIN projects_users as certifier_project_users ON certifier_project_users.user_id = certifier_users.id  WHERE certifier_project_users.role IN (3,4) AND certifier_project_users.project_id = projects.id), '|||') AS certifiers_array")
                   .select("ARRAY_TO_STRING(ARRAY(SELECT enterprise_client_users.email FROM users as enterprise_client_users INNER JOIN projects_users as enterprise_client_project_users ON enterprise_client_project_users.user_id = enterprise_client_users.id  WHERE enterprise_client_project_users.role IN (2) AND enterprise_client_project_users.project_id = projects.id), '|||') AS enterprise_clients_array")
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