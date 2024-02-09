module Offline
  class Project < ApplicationRecord
    has_many :offline_project_documents, class_name: 'Offline::ProjectDocument', foreign_key: 'offline_project_id', inverse_of: :offline_project, dependent: :destroy
    has_many :offline_certification_paths, class_name: 'Offline::CertificationPath', foreign_key: 'offline_project_id', inverse_of: :offline_project, dependent: :destroy

    validates :code, :name, :developer, :certificate_type, presence: true

    enum certificate_type:
      [
        "Energy Centers Efficiency",
        "Building Energy Efficiency",
        "Healthy Buildings",
        "Indoor Air Quality",
        "Measurement, Reporting And Verification (MRV)",
        "Buildings Water Efficiency",
        "Events Carbon Neutrality",
        "Products Ecolabeling",
      ]

    
    enum assessment_method: 
      [
        "Checklist Assessment"
      ]

    def self.datatable_projects_records
      self
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
                'offline_projects.assessment_method',
                'offline_projects.construction_year',
                'offline_projects.project_country',
                'offline_projects.project_city',
                'offline_projects.project_district',
                'offline_projects.project_owner_business_sector',
                'offline_projects.project_developer_business_sector',
                'offline_projects.project_gross_built_up_area',
                'offline_certification_paths.id as certification_id',
                'offline_certification_paths.name as certification_name',
                'offline_certification_paths.version as certification_version',
                'offline_certification_paths.development_type as certification_development_type',
                'offline_certification_paths.status as certification_status',
                'offline_certification_paths.certified_at as certification_certified_at',
                'offline_certification_paths.rating as certification_rating')
        .select('(%s) AS certification_scheme_name' % ApplicationController.helpers.offline_projects_by_scheme_names)
        .select('(%s) AS subschemes' % ApplicationController.helpers.offline_projects_by_sub_scheme_names)
    end
  end
end
