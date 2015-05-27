class SchemeCriterion < ActiveRecord::Base
  belongs_to :scheme
  belongs_to :criterion
  has_many :scores
  has_many :scheme_mix_criteria
  has_many :scheme_criterion_requirements
  has_many :requirements, through: :scheme_criterion_requirements

  def max_attainable_score
    scores.maximum(:score)
  end

  default_scope {
    joins(:criterion)
    .order('criteria.name')
  }
end
