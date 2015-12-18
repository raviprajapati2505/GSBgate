class SchemeMixCriteriaRequirementDatum < ActiveRecord::Base
  belongs_to :scheme_mix_criterion
  belongs_to :requirement_datum, dependent: :destroy
end
