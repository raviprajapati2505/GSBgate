class Scheme < ActiveRecord::Base
  belongs_to :certificate
  has_many :scheme_mixes
  has_many :certification_paths, through: :scheme_mixes
  has_many :scheme_criteria

  def full_label
    "GSAS #{Certificate.human_attribute_name(self.certificate.assessment_stage)} Assessment v#{version}: #{label}"
  end

  def maximum_attainable_score
    Scheme.calculate_score(scheme_criteria, 'maximum_attainable_score')
  end

  def minimum_attainable_score
    Scheme.calculate_score(scheme_criteria, 'minimum_attainable_score')
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
    # Class method to calculate the weighted score for this scheme mix
    def calculate_score(sc, score_method)
      # First determine the total score of all scheme_criteria
      total = nil
      sc.each do |scheme_criterion|
        total ||= 0
        total += scheme_criterion.send(score_method)
      end
      raise 'scheme without scheme mix criteria' if total.nil?
      total
    end

end
