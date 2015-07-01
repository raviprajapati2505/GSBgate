class SchemeMixCriteriaDocument < ActiveRecord::Base
  belongs_to :document
  belongs_to :scheme_mix_criterion
  has_many :scheme_mix_criteria_document_comments
end
