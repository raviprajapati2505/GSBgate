class SchemeCriteriaRequirement < ApplicationRecord
  belongs_to :scheme_criterion, optional: true
  belongs_to :requirement, optional: true
end
