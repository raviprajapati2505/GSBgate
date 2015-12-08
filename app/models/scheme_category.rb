class SchemeCategory < ActiveRecord::Base
  has_many :scheme_criteria
  has_many :scheme_mix_criteria, through: :scheme_criteria
  has_many :scheme_mix_criteria_documents, through: :scheme_mix_criteria
  belongs_to :scheme
  default_scope { order(display_weight: :asc) }
end
