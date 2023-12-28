class Document < BaseDocument
  has_many :scheme_mix_criteria_documents, dependent: :destroy
  has_many :scheme_mix_criteria, through: :scheme_mix_criteria_documents

  accepts_nested_attributes_for :scheme_mix_criteria_documents, :allow_destroy => true

  validates :scheme_mix_criteria_documents, :presence => true
end
