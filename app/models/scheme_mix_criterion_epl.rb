class SchemeMixCriterionEpl < SchemeMixCriterionPerformanceLabel
  include Auditable

  # belongs_to :scheme_criterion_epl
  belongs_to :scheme_criterion_performance_label, foreign_key: 'scheme_criterion_performance_labels_id'

  default_scope { includes(:scheme_criterion_performance_label).order('scheme_criterion_performance_labels.display_weight ASC')}

  def total_energy_consumption
    total_consumption = 0
    total_consumption += self.cooling unless self.cooling.nil?
    total_consumption += self.lighting unless self.lighting.nil?
    total_consumption += self.auxiliaries unless self.auxiliaries.nil?
    total_consumption += self.dhw unless self.dhw.nil?
    total_consumption += self.others unless self.others.nil?
    total_consumption += self.generation unless self.generation.nil?
    total_consumption += self.co2_emission unless self.co2_emission.nil?
    return total_consumption
  end
end
