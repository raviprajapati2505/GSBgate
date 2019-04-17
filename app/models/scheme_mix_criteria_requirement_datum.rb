class SchemeMixCriteriaRequirementDatum < ApplicationRecord
  belongs_to :scheme_mix_criterion, optional: true
  belongs_to :requirement_datum, optional: true
end
