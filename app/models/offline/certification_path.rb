module Offline
  class CertificationPath < ApplicationRecord
    belongs_to :offline_project, class_name: 'Offline::Project', foreign_key: 'offline_project_id', inverse_of: :offline_certification_paths
    has_many :offline_scheme_mixes, class_name: 'Offline::SchemeMix', foreign_key: 'offline_certification_path_id', inverse_of: :offline_certification_path, dependent: :destroy
    
    accepts_nested_attributes_for :offline_scheme_mixes

    validates :name, :version, :development_type, :status, :rating, presence: true

    enum version:
      [
        "v1.0",
        "v2.0",
        "v2.1"
      ]

    enum rating:
      [ 
        "1 Stars",
        "2 Stars",
        "3 Stars",
        "4 Stars",
        "5 Stars",
        "6 Stars"
      ]
  end
end