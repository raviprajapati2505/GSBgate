class Scheme < ActiveRecord::Base
  belongs_to :certificate
  has_many :scheme_mixes
  has_many :certification_paths, through: :scheme_mixes
  has_many :scheme_criteria

  def full_label
    "GSAS #{Certificate.human_attribute_name(self.certificate.assessment_stage)} Assessment v#{version}: #{label}"
  end

  # returns the total of all weights for the criteria belonging to the specified category
  def total_weight_for_category(category)
    scheme_criteria.for_category(category).sum(:weight)
  end

  def max_attainable_score_for_category(category)
    scheme_criteria.for_category(category).joins(:scores).maximum(:score)
  end

  def min_score_for_category(category)
    scheme_criteria.for_category(category).joins(:scores).minimum(:score)
  end

  # returns the total of all weighted max attainable scores (see scheme_criterion#weighted_max_attainable_score) for the criteria belonging to the specified category
  def weighted_max_attainable_score_for_category(category)
    weighted_max_attainable_score = 0
    scheme_criteria.for_category(category).each do |scheme_criterion|
      weighted_max_attainable_score += scheme_criterion.scores.to_a.max_by(&:score).score * scheme_criterion.weight / 100
    end
    return weighted_max_attainable_score
  end

  def weighted_min_score_for_category(category)
    weighted_min_score = 0
    scheme_criteria.for_category(category).each do |scheme_criterion|
      weighted_min_score += scheme_criterion.scores.to_a.min_by(&:score).score * scheme_criterion.weight / 100
    end
    return weighted_min_score
  end

  def weighted_max_attainable_score
    weighted_max_attainable_score = 0
    scheme_criteria.each do |scheme_criterion|
      weighted_max_attainable_score += scheme_criterion.scores.to_a.max_by(&:score).score * scheme_criterion.weight / 100
    end
    return weighted_max_attainable_score
  end

  def weighted_min_score
    weighted_min_score = 0
    scheme_criteria.each do |scheme_criterion|
      weighted_min_score += scheme_criterion.scores.to_a.min_by(&:score).score * scheme_criterion.weight / 100
    end
    return weighted_min_score
  end

end
