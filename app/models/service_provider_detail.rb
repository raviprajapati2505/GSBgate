class ServiceProviderDetail < ApplicationRecord
  MAXIMUM_DOCUMENT_FILE_SIZE = 25 # in MB

  belongs_to :service_provider, class_name: "User", foreign_key: 'service_provider_id'

  validates :business_field, :portfolio, :commercial_licence_file, :accredited_service_provider_licence_file, :demerit_acknowledgement_file,  presence: true
  validates :commercial_licence_file, :accredited_service_provider_licence_file, :demerit_acknowledgement_file, file_size: {maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }

  mount_uploader :commercial_licence_file, UserSubmittalUploader
  mount_uploader :accredited_service_provider_licence_file, UserSubmittalUploader
  mount_uploader :demerit_acknowledgement_file, UserSubmittalUploader
  mount_uploader :application_form, UserSubmittalUploader
end
