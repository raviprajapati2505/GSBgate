class SchemeCriterionPerformanceLabel < ApplicationRecord
  # TODO include Auditable

  belongs_to :scheme_criterion, optional: true
  serialize :levels
  serialize :bands

  default_scope { order(display_weight: :asc)}
end
