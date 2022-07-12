module Offline
  class Project < ApplicationRecord
    has_many :offline_project_documents, class_name: 'Offline::ProjectDocument', foreign_key: 'offline_project_id', inverse_of: :offline_project, dependent: :destroy
    has_many :offline_certification_paths, class_name: 'Offline::CertificationPath', foreign_key: 'offline_project_id', inverse_of: :offline_project, dependent: :destroy

    validates :name, :developer, :certificate_type, :construction_year, :certified_area, :site_area, presence: true
  end
end
