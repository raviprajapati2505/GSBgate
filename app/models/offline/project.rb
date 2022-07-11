module Offline
  class Project < ApplicationRecord

    MAXIMUM_DOCUMENT_FILE_SIZE = 100 # in MB

    has_many :offline_certificate_paths, class_name: 'Offline::CertificatePath', foreign_key: 'offline_project_id',inverse_of: :offline_project, dependent: :destroy

    validates :name, :developer, :certificate_type, :construction_year, :certified_area, :site_area, presence: true
    
    mount_uploader :documents, GeneralSubmittalUploader
  end
end