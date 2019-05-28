class SchemeCriterionIncentive < ApplicationRecord
  include Auditable

  belongs_to :scheme_criterion, optional: true

  default_scope { order(label: :asc) }

  scope :for_category, ->(scheme, category) {
    joins(scheme_criterion: [scheme_category: [:scheme]]).where(schemes: {id: scheme.id}, scheme_criteria: {scheme_category_id: category.id})
  }

end
