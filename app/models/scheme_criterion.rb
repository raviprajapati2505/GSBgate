class SchemeCriterion < ActiveRecord::Base
  belongs_to :scheme_category
  has_many :scheme_criterion_texts
  has_many :scheme_mix_criteria
  has_many :scheme_criteria_requirements
  has_many :requirements, through: :scheme_criteria_requirements
  serialize :scores

  scope :for_category, ->(category) {
    where(scheme_category_id: category.id)
  }

  def full_name
    "#{self.scheme_category.code}#{self.number}: #{self.name}"
  end

  def minimum_attainable_score
    scores.min
  end

  def maximum_attainable_score
    scores.max
  end

  def weighted_minimum_attainable_score
    weighted_score(minimum_attainable_score)
  end

  def weighted_maximum_attainable_score
    weighted_score(maximum_attainable_score)
  end

  def weighted_score(score)
    # returns weighted score, taking into account the percentage for which it counts (=weight)
    #NOTE: we multiply the weight with 3, as we need a final score on a scale based on a total of 3, not 1
    (score / maximum_attainable_score) * ((3 * weight) / 100)
  end

  # default_scope {
  #   joins(:criterion)
  #   .order('criteria.name')
  # }
end
