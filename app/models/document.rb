require 'file_size_validator'

class Document < ActiveResource
  MAXIMUM_DOCUMENT_FILE_SIZE = 25 # in MB

  belongs_to :user
  has_many :scheme_mix_criteria_documents
  has_many :scheme_mix_criteria, through: :scheme_mix_criteria_documents

  mount_uploader :document_file, DocumentUploader
  validates :document_file, file_size: {maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }
end
