require 'roo'

scheme_criteria = SchemeCriterion.joins(:scheme_category).where('scheme_criteria.number IN (?) AND scheme_categories.code = ?', [1,2,3], 'MO').includes(:scheme_criterion_incentives)

scheme_criteria.each do |scheme_criterion|
  unless scheme_criterion.scheme_criterion_incentives.present?
 
    4.times do |i|
      SchemeCriterionIncentive.find_or_create_by(scheme_criterion_id: scheme_criterion.id, incentive_weight: 0.5, label: "Additional Low-VOC material #{i+1} (+0.5%)", display_weight: i+1 )
    end
  end
end
