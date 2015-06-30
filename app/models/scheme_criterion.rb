class SchemeCriterion < ActiveRecord::Base
  belongs_to :scheme
  belongs_to :criterion
  has_many :scores
  has_many :scheme_mix_criteria
  has_many :scheme_criteria_requirements
  has_many :requirements, through: :scheme_criteria_requirements

  scope :for_category, ->(category) {
    joins(:criterion).where(criteria: {category_id: category.id})
  }

  def max_attainable_score
    scores.maximum(:score)
  end

  # returns max attainable score taking into account the percentage for which it counts (=weight)
  def weighted_max_attainable_score
    scores.maximum(:score) * weight / 100
  end

  default_scope {
    joins(:criterion)
    .order('criteria.name')
  }
end
