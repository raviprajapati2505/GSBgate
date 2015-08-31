class SchemeCriteriaRequirement < ActiveRecord::Base
  belongs_to :scheme_criterion
  belongs_to :requirement
end
