class SchemeCategory < ApplicationRecord
  include Auditable

  has_many :scheme_criteria
  has_many :scheme_mix_criteria, through: :scheme_criteria
  has_many :scheme_mix_criteria_documents, through: :scheme_mix_criteria
  belongs_to :scheme, optional: true
  default_scope { order(display_weight: :asc) }
end
