class SchemeCriterionText < ApplicationRecord
  include Auditable

  belongs_to :scheme_criterion, optional: true

  default_scope { order(display_weight: :asc) }

  scope :visible, -> {
    where(visible: true)
  }
end
