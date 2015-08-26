class SchemeCriterion < ActiveResource
  enum score_combination_type: [ :score_combination_unknown, :score_combination_only_a, :score_combination_average ]
  serialize :score_a
  serialize :score_b
  belongs_to :scheme
  belongs_to :criterion
  has_many :scheme_mix_criteria
  has_many :scheme_criteria_requirements
  has_many :requirements, through: :scheme_criteria_requirements

  scope :for_category, ->(category) {
    joins(:criterion).where(criteria: {category_id: category.id})
  }

  def minimum_attainable_score
    calculate_score_combination('minimum_attainable_score')
  end

  def maximum_attainable_score
    calculate_score_combination('maximum_attainable_score')
  end

  def maximum_attainable_score_a
    return nil if score_a.nil?
    score_a['score_values'].keys.max
  end

  def maximum_attainable_score_b
    return nil if score_b.nil?
    score_b['score_values'].keys.max
  end

  def minimum_attainable_score_a
    return nil if score_a.nil?
    score_a['score_values'].keys.min
  end

  def minimum_attainable_score_b
    return nil if score_b.nil?
    score_b['score_values'].keys.min
  end

  # returns max attainable score taking into account the percentage for which it counts (=weight)
  def weighted_minimum_attainable_score
    minimum_attainable_score * weight / 100
  end

  def weighted_maximum_attainable_score
    maximum_attainable_score * weight / 100
  end

  default_scope {
    joins(:criterion)
    .order('criteria.name')
  }

  private
    # Class method to calculate the score combination for this scheme criterion
    def calculate_score_combination(score_method)
      if self.score_combination_only_a?
        self.send(score_method + '_a')
      elsif self.score_combination_average?
        (self.send(score_method + '_a') + self.send(score_method + '_b')) / 2
      else
        raise 'unknown score combination type: ' + self.score_combination_type
      end
    end
end
