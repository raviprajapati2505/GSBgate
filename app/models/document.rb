class Document < ActiveRecord::Base
  belongs_to :user
  has_many :scheme_mix_criteria_documents
  has_many :scheme_mix_criteria, through: :scheme_mix_criteria_documents

  mount_uploader :document_file, DocumentUploader

  def to_s
    (ActionController::Base.helpers.image_tag(Icon.for_filename(self.document_file.file.filename), alt: self.document_file.content_type, title: self.document_file.content_type) + ' ' + ActionController::Base.helpers.link_to(self.document_file.file.filename, self.document_file.url, target: '_blank')).html_safe
  end
end
