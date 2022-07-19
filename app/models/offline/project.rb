module Offline
  class Project < ApplicationRecord
    has_many :offline_project_documents, class_name: 'Offline::ProjectDocument', foreign_key: 'offline_project_id', inverse_of: :offline_project, dependent: :destroy
    has_many :offline_certification_paths, class_name: 'Offline::CertificationPath', foreign_key: 'offline_project_id', inverse_of: :offline_project, dependent: :destroy

    validates :code, :name, :developer, :certificate_type, :certified_area, :plot_area, presence: true

    enum certificate_type:
      [
        "GSAS-D&B",
        "GSAS-CM",
        "GSAS-OP"
      ]

    
    enum assessment_type: 
      [
        "Star Rating Based Certificate",
        "Checklist Based Certificate"
      ]
  end
end
