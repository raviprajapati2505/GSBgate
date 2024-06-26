class ServiceProviderDetail < ApplicationRecord
  MAXIMUM_DOCUMENT_FILE_SIZE = 25 # in MB

  belongs_to :service_provider, class_name: "User", foreign_key: 'service_provider_id'

  validates :business_field, :portfolio, :commercial_licence_file, :cgp_licence_file, :nominated_cgp, :demerit_acknowledgement_file, :exam, :workshop,  presence: true
  validates :commercial_licence_file, :accredited_service_provider_licence_file, :demerit_acknowledgement_file, :exam, :workshop, file_size: {maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }

  mount_uploader :commercial_licence_file, UserSubmittalUploader
  mount_uploader :accredited_service_provider_licence_file, UserSubmittalUploader
  mount_uploader :demerit_acknowledgement_file, UserSubmittalUploader
  mount_uploader :application_form, UserSubmittalUploader
  mount_uploader :portfolio, UserSubmittalUploader
  mount_uploader :cgp_licence_file, UserSubmittalUploader
  mount_uploader :gsb_energey_assessment_licence_file, UserSubmittalUploader
  mount_uploader :exam, UserSubmittalUploader
  mount_uploader :workshop, UserSubmittalUploader
end
