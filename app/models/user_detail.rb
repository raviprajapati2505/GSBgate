class UserDetail < ApplicationRecord
  MAXIMUM_DOCUMENT_FILE_SIZE = 25 # in MB

  belongs_to :user

  validates :gender, :qid_file, :university_credentials_file, :work_experience_file, :cgp_licence_file, :qid_work_permit_file, :gsas_energey_assessment_licence_file, :qid_or_passport_number, presence: true
  validates :qid_file, :university_credentials_file, :work_experience_file, :cgp_licence_file, :qid_work_permit_file, :gsas_energey_assessment_licence_file, file_size: {maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }

  mount_uploader :qid_file, UserSubmittalUploader
  mount_uploader :university_credentials_file, UserSubmittalUploader
  mount_uploader :work_experience_file, UserSubmittalUploader
  mount_uploader :cgp_licence_file, UserSubmittalUploader
  mount_uploader :qid_work_permit_file, UserSubmittalUploader
  mount_uploader :gsas_energey_assessment_licence_file, UserSubmittalUploader
end
