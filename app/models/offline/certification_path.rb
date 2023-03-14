module Offline
  class CertificationPath < ApplicationRecord
    MAXIMUM_DOCUMENT_FILE_SIZE = 100 # in MB
    
    belongs_to :offline_project, class_name: 'Offline::Project', foreign_key: 'offline_project_id', inverse_of: :offline_certification_paths
    has_many :offline_scheme_mixes, class_name: 'Offline::SchemeMix', foreign_key: 'offline_certification_path_id', inverse_of: :offline_certification_path, dependent: :destroy
    
    accepts_nested_attributes_for :offline_scheme_mixes

    mount_uploader :signed_certificate_file, OfflineProjectsDocumentUploader

    validates :signed_certificate_file, file_size: {maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }
    validates :name, :version, :development_type, :status, presence: true

    enum version:
      [
        "v1.0",
        "v2.0",
        "v2.1",
        "v2.1 Issue 1.0"
      ]

    enum rating:
      [ 
        "1 Stars",
        "2 Stars",
        "3 Stars",
        "4 Stars",
        "5 Stars",
        "6 Stars",
        "CERTIFIED",
        "CLASS B"
      ]
  end
end