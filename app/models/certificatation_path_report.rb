require 'file_size_validator'

class CertificatationPathReport < ApplicationRecord
  belongs_to :certification_path
  mount_uploader :rendering_image, ImageUploader

  MAXIMUM_DOCUMENT_FILE_SIZE = 25 # in MB

  validates :to, :reference_number, :project_owner, :designation, :service_provider, :project_name, :project_location, :issuance_date, :approval_date, :rendering_image, presence: true

  validates :rendering_image, file_size: { maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }
end
