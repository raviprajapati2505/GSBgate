class SchemeCriterion < ActiveRecord::Base
  include Auditable

  belongs_to :scheme_category
  has_many :scheme_criterion_texts
  has_many :scheme_mix_criteria
  has_many :scheme_criteria_requirements
  has_many :requirements, through: :scheme_criteria_requirements
  serialize :scores

  scope :for_category, ->(category) {
    where(scheme_category_id: category.id)
  }

  def code
    "#{self.scheme_category.code}.#{self.number}"
  end

  def full_name
    "#{self.code}: #{self.name}"
  end

  def minimum_score
    scores.min
  end

  def maximum_score
    scores.max
  end

  def weighted_score(score)
    # returns weighted score, taking into account the percentage for which it counts (=weight)
    #NOTE: we multiply the weight with 3, as we need a final score on a scale based on a total of 3, not 1
    (score.to_f  / maximum_score.to_f ) * ((3.to_f  * weight.to_f ) / 100.to_f)
  end

  # default_scope {
  #   joins(:criterion)
  #   .order('criteria.name')
  # }
end
