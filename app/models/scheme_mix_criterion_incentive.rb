class SchemeMixCriterionIncentive < ApplicationRecord
  include Auditable

  belongs_to :scheme_mix_criterion
  belongs_to :scheme_criterion_incentive

end
