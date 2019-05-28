class SchemeMixCriterionEpl < SchemeMixCriterionPerformanceLabel
  include Auditable

  # belongs_to :scheme_criterion_epl
  belongs_to :scheme_criterion_performance_label, foreign_key: 'scheme_criterion_performance_labels_id'

  default_scope { includes(:scheme_criterion_performance_label).order('scheme_criterion_performance_labels.display_weight ASC')}

end
