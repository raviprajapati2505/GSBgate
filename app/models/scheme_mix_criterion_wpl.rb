class SchemeMixCriterionWpl < SchemeMixCriterionPerformanceLabel
  include Auditable

  # belongs_to :scheme_criterion_wpl
  belongs_to :scheme_criterion_performance_label, foreign_key: 'scheme_criterion_performance_labels_id'

  default_scope { includes(:scheme_criterion_performance_label).order('scheme_criterion_performance_labels.display_weight ASC')}

  def total_water_consumption
    total_consumption = 0
    total_consumption += self.indoor_use unless self.indoor_use.nil?
    total_consumption += self.irrigation unless self.irrigation.nil?
    total_consumption += self.cooling_tower unless self.cooling.nil?
    return total_consumption
  end
end
