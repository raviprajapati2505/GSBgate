require 'file_size_validator'

class BaseDocument < ApplicationRecord
  MAXIMUM_DOCUMENT_FILE_SIZE = 100 # in MB

  self.table_name = 'documents'

  belongs_to :user, optional: true

  mount_uploader :document_file, DocumentUploader
  validates :document_file, file_size: {maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }

  def name
    self.document_file.file.filename
  end

  def content_type
    self.document_file.content_type
  end

  def path
    self.document_file.file.path
  end

  def size
    self.document_file.size
  end
end