class SchemeMixCriterionPerformanceLabel < ApplicationRecord
  # self.abstract_class = true

  belongs_to :scheme_mix_criterion
  # belongs_to :scheme_criterion_performance_label

  # default_scope { includes(:scheme_criterion_performance_labels).order('scheme_criterion_performance_labels.display_weight ASC')}
end
