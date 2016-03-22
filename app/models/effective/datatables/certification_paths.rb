module Effective
  module Datatables
    class CertificationPaths < Effective::Datatable
      include ActionView::Helpers::TranslationHelper
      attr_accessor :current_ability

      datatable do
        # Project
        table_column :project, filter: {type: :select, values: Proc.new { Project.all.map { |project| [project.name, project.id] } }} do |certification_path|
          can_link_to(project_path(certification_path.project), certification_path.project) do
            certification_path.project.code + ', ' + certification_path.project.name
          end
        end
        table_column 'project_owner', column: 'projects.owner' do |certification_path|
          certification_path.project.owner
        end
        table_column 'project_code', visible: false, type: :string, column: 'projects.code' do |certification_path|
          can_link_to(project_path(certification_path.project), certification_path.project) do
            certification_path.project.code
          end
        end
        table_column 'project_name', visible: false, type: :string, column: 'projects.name' do |certification_path|
          can_link_to(project_path(certification_path.project), certification_path.project) do
            certification_path.project.name
          end
        end
        table_column 'project_construction_year', visible: false, type: :string, column: 'projects.construction_year' do |certification_path|
          certification_path.project.construction_year
        end
        table_column 'project_country', visible: false, type: :string, column: 'projects.country' do |certification_path|
          certification_path.project.country
        end
        table_column 'project_description', visible: false, type: :string, column: 'projects.description' do |certification_path|
          certification_path.project.description
        end
        table_column 'project_gross_area', visible: false, type: :integer, column: 'projects.gross_area' do |certification_path|
          certification_path.project.gross_area
        end
        table_column 'project_certified_area', visible: false, type: :integer, column: 'projects.certified_area' do |certification_path|
          certification_path.project.certified_area
        end
        table_column 'project_carpark_area', visible: false, type: :integer, column: 'projects.carpark_area' do |certification_path|
          certification_path.project.carpark_area
        end
        table_column 'project_site_area', visible: false, type: :integer, column: 'projects.project_site_area' do |certification_path|
          certification_path.project.project_site_area
        end
        table_column 'project_created_at', visible: false, column: 'projects.created_at', filter: {type: :select, values: Proc.new {
          Project.pluck_date_field_by_year_month_day(:created_at, :desc) }
        }
        # # Certificate
        table_column :certificate, filter: {values: Proc.new { Certificate.all.order(:display_weight).map { |certificate| [certificate.full_name, certificate.id] } }} do |certification_path|
          can_link_to(project_certification_path_path(certification_path.project, certification_path), certification_path) do
            certification_path.certificate.full_name
          end
        end
        # CertificationPathStatus
        table_column :certification_path_status, label: t('models.effective.datatables.certification_paths.certification_path_status.label'),
                     filter: {type: :select, values: Proc.new { CertificationPathStatus.all.map { |status| [status.name, status.id] } }
                     } do |certification_path|
          certification_path.certification_path_status.name
        end

        # Note:
        # -- custom filtering, see search_column method below !!
        # -- sorting does not work with custom search
        table_column 'certification_path_status_progress', label: 'State', sortable: false, filter: {type: :select, values: ['In progress', 'Completed'] } do |certification_path|
          certification_path.is_completed? ? 'Completed' : 'In Progress'
        end

        # Certification path
        table_column :pcr_track, visible: false
        table_column :development_type, visible: false, filter: {type: :select, values: Proc.new { CertificationPath.development_types.map { |k| [t(k[0], scope: 'activerecord.attributes.certification_path.development_types'), k[1]] } }
        } do |certification_path|
          t(certification_path.development_type, scope: 'activerecord.attributes.certification_path.development_types')
        end
        table_column :appealed, visible: false
        table_column :created_at, visible: false, filter: {type: :select, values: Proc.new { CertificationPath.pluck_date_field_by_year_month_day(:created_at, :desc) }}
        table_column :started_at, visible: false, filter: {type: :select, values: Proc.new { CertificationPath.pluck_date_field_by_year_month_day(:started_at, :desc) }}
        table_column :certified_at, visible: false, filter: {type: :select, values: Proc.new { CertificationPath.pluck_date_field_by_year_month_day(:certified_at, :desc) }}
        table_column :duration, visible: false

        # TODO: when a score has been achieved, cache its value in the certification_path, so we can sort/filter it serverside
        # array_column :score, visible: false, sortable: false, filter: false do |certification_path|
        #   certification_path.scores_in_certificate_points[:achieved]
        # end
      end

      def collection
        coll = CertificationPath.all unless current_ability.present?
        coll = CertificationPath.accessible_by(current_ability) if current_ability.present?
        coll.includes(:certificate)
            .includes(project: [:owner])
            .references(:projects)
            .includes(:certification_path_status)
      end

      def search_column(collection, table_column, search_term)
        if table_column[:name] == 'certification_path_status_progress'
          return collection.with_status(CertificationPathStatus::STATUSES_IN_PROGRESS) if search_term == 'In progress'
          return collection.with_status(CertificationPathStatus::STATUSES_COMPLETED) if search_term == 'Completed'
          super
        else
          super
        end
      end

    end
  end
end