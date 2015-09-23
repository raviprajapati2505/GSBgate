class SchemeCriterionText < ActiveRecord::Base
  belongs_to :scheme_criterion

  default_scope { order(display_weight: :asc) }
end
