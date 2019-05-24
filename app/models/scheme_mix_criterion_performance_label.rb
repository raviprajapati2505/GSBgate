class SchemeMixCriterionPerformanceLabel < ApplicationRecord
  # include Auditable

  belongs_to :scheme_mix_criterion
  belongs_to :scheme_criterion_performance_label

  default_scope { includes(:scheme_criterion_performance_label).order('scheme_criterion_performance_label.display_weight ASC')}
end
