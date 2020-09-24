class SchemeMixCriterionBox < ApplicationRecord
  belongs_to :scheme_mix_criterion
  belongs_to :scheme_criterion_box
  default_scope { order(created_at: :asc) }
end
