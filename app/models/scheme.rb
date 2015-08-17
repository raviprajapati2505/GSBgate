class Scheme < ActiveRecord::Base
  belongs_to :certificate
  has_many :scheme_mixes
  has_many :certification_paths, through: :scheme_mixes
  has_many :scheme_criteria

  def full_label
    "GSAS #{Certificate.human_attribute_name(self.certificate.assessment_stage)} Assessment v#{version}: #{label}"
  end

  def maximum_attainable_score
    calculate_score(scheme_criteria, 'maximum_attainable_score')
  end

  def minimum_attainable_score
    calculate_score(scheme_criteria, 'minimum_attainable_score')
  end

  # returns the total of all weights for the criteria belonging to the specified category
  def total_weight_for_category(category)
    scheme_criteria.for_category(category).sum(:weight)
  end

  def maximum_attainable_score_for_category(category)
    calculate_score(scheme_criteria.for_category(category), 'maximum_attainable_score')
  end

  def minimum_attainable_score_for_category(category)
    calculate_score(scheme_criteria.for_category(category), 'minimum_attainable_score')
  end

  # returns the total of all weighted max attainable scores (see scheme_criterion#weighted_maximum_attainable_score) for the criteria belonging to the specified category
  def weighted_maximum_attainable_score_for_category(category)
    calculate_score(scheme_criteria.for_category(category), 'weighted_maximum_attainable_score')
  end

  def weighted_mininum_attainable_score_for_category(category)
    calculate_score(scheme_criteria.for_category(category), 'weighted_minimum_attainable_score')
  end

  def weighted_maximum_attainable_score
    calculate_score(scheme_criteria, 'weighted_maximum_attainable_score')
  end

  def weighted_minimum_attainable_score
    calculate_score(scheme_criteria, 'weighted_minimum_attainable_score')
  end

  private
    def calculate_score(sc, score_method)
      result = nil
      sc.each do |scheme_criterion|
        result ||= scheme_criterion.send(score_method)
        if score_method.include? 'minimum'
          result = [result, scheme_criterion.send(score_method)].min
        elsif score_method.include? 'maximum'
          result = [result, scheme_criterion.send(score_method)].max
        else
          raise 'unexpected score_method: ' + score_method
        end
      end
      raise 'scheme without scheme mix criteria' if result.nil?
      result
    end

end
