class Scheme < ActiveRecord::Base
  belongs_to :certificate
  has_many :scheme_categories
  has_many :scheme_criteria, through: :scheme_categories
  has_many :scheme_mixes
  has_many :scheme_mix_criteria, through: :scheme_mixes
  has_many :certification_paths, through: :scheme_mixes

  def full_name
    "GSAS #{Certificate.human_attribute_name(self.certificate.assessment_stage)} Assessment v#{version}: #{name}"
  end

  # returns the total of all weights for the criteria belonging to the specified category
  def total_weight_for_category(category)
    scheme_criteria.for_category(category).sum(:weight)
  end

  # returns the total of all weighted max attainable scores (see scheme_criterion#weighted_maximum_attainable_score) for the criteria belonging to the specified category
  def weighted_maximum_attainable_score_for_category(category)
    calculate_score(scheme_criteria.for_category(category), 'weighted_maximum_attainable_score')
  end

  def weighted_maximum_attainable_score
    calculate_score(scheme_criteria, 'weighted_maximum_attainable_score')
  end

  def weighted_minimum_attainable_score
    calculate_score(scheme_criteria, 'weighted_minimum_attainable_score')
  end

  def maximum_maximum_attainable_score_by_category
    max_scores = scheme_categories.collect{ |category|
      max_scores_category = scheme_criteria.for_category(category).collect{|sc|
        sc.maximum_attainable_score
      }
      max_scores_category.max
    }
    max_scores.max
  end

  def minimum_minimum_attainable_score_by_category
    min_scores = scheme_categories.collect{ |category|
      min_scores_category = scheme_criteria.for_category(category).collect{|sc|
        sc.minimum_attainable_score
      }
      min_scores_category.min
    }
    min_scores.min
  end

  def maximum_weighted_maximum_attainable_score_by_category
    score = nil
    scheme_categories.each do |category|
      score ||= calculate_score(scheme_criteria.for_category(category), 'weighted_maximum_attainable_score')
      score = [score, calculate_score(scheme_criteria.for_category(category), 'weighted_maximum_attainable_score')].max
    end
    score
  end

  def minimum_weighted_minimum_attainable_score_by_category
    score = nil
    scheme_categories.each do |category|
      score ||= calculate_score(scheme_criteria.for_category(category), 'weighted_minimum_attainable_score')
      score = [score, calculate_score(scheme_criteria.for_category(category), 'weighted_minimum_attainable_score')].min
    end
    score
  end

  private
    def calculate_score(sc, score_method)
      result = nil
      sc.each do |scheme_criterion|
        result ||= 0
        if scheme_criterion.respond_to?(score_method)
          result += scheme_criterion.send(score_method)
        else
          raise 'unexpected score_method: ' + score_method
        end
      end
      raise 'scheme without scheme mix criteria' if result.nil?
      result
    end

end
