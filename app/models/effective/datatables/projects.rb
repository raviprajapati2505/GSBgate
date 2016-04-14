module Effective
  module Datatables
    class Projects < Effective::Datatable

      attr_accessor :current_ability

      datatable do
        # Project
        table_column :name do |project|
          can_link_to(project_path(project), project) do
            project.code + ', ' + project.name
          end
        end
        table_column 'project_owner', column: 'owner' do |project|
          project.owner
        end
        table_column 'project_developer', column: 'developer' do |project|
          project.developer
        end
        table_column :created_at, filter: {type: :select, values: Proc.new {
          projects = Project.all
          if attributes.has_key?(:empty_projects)
            projects = projects.without_certification_paths
          end
          projects.pluck_date_field_by_year_month_day(:created_at, :desc) }
        }
        table_column :construction_year, visible: false
        table_column :country, visible: false
        table_column :location, visible: false
        table_column :address, visible: false
        table_column :description, visible: false
      end

      def collection
        coll = Project.all unless current_ability.present?
        coll = Project.accessible_by(current_ability) if current_ability.present?
        coll = coll.includes(:owner)

        # ONLY SHOWS PROJECTS WITHOUT A CERTIFICATION PATH !!
        if attributes.has_key?(:empty_projects)
          coll = coll.without_certification_paths
        end

        return coll
      end

    end
  end
end