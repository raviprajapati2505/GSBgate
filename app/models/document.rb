class Document < ActiveRecord::Base
  belongs_to :owner, class_name: 'User', inverse_of: :owned_documents
  has_many :scheme_mix_criteria_documents
  has_many :scheme_mix_criteria, through: :scheme_mix_criteria_documents

  mount_uploader :document_file, DocumentUploader
end
