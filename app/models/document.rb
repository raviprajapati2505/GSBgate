require 'file_size_validator'

class Document < ActiveRecord::Base
  MAXIMUM_DOCUMENT_FILE_SIZE = 10 # in MB

  belongs_to :user
  has_many :scheme_mix_criteria_documents
  has_many :scheme_mix_criteria, through: :scheme_mix_criteria_documents

  accepts_nested_attributes_for :scheme_mix_criteria_documents, :allow_destroy => true

  mount_uploader :document_file, DocumentUploader
  validates :document_file, file_size: {maximum: MAXIMUM_DOCUMENT_FILE_SIZE.megabytes.to_i }
  validates :scheme_mix_criteria_documents, :presence => true

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
