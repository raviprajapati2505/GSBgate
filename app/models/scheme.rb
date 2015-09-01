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

  # sums the weights for all scheme_criteria belonging to the given category
  def total_weight_for_category(category)
    scheme_criteria.for_category(category).sum(:weight)
  end

  # returns the total of all weighted max attainable scores
  def total_weighted_maximum_attainable_score_for_category(category)
    scheme_criteria.for_category(category).collect {|sc| sc.weighted_maximum_attainable_score}.inject(:+)
  end

  # sums the weighted_maximum_attainable_score for all scheme_criteria
  def total_weighted_maximum_attainable_score
    scheme_criteria.collect {|sc| sc.weighted_maximum_attainable_score}.inject(:+)
  end

  # sums the weighted_minimum_attainable_score for all scheme_criteria
  def total_weighted_minimum_attainable_score
    scheme_criteria.collect {|sc| sc.weighted_minimum_attainable_score}.inject(:+)
  end

  def maximum_attainable_score_for_scheme
    scheme_criteria.collect{|sc| sc.maximum_attainable_score}.max
  end

  def minimum_attainable_score_for_scheme
    scheme_criteria.collect{|sc| sc.minimum_attainable_score}.min
  end

  def maximum_of_total_weighted_maximum_attainable_score_per_category
    scheme_criteria_per_category = scheme_criteria.group_by{|scheme_criterion| scheme_criterion.scheme_category}
    weighted_maximum_attainable_score_summed_per_category = scheme_criteria_per_category.values.collect { |sc_cat|
      sc_cat.collect { |sc| sc.weighted_maximum_attainable_score}.inject(:+)
    }
    weighted_maximum_attainable_score_summed_per_category.max
  end

  def minimum_of_total_weighted_minimum_attainable_score_per_category
    scheme_criteria_per_category = scheme_criteria.group_by{|scheme_criterion| scheme_criterion.scheme_category}
    weighted_minimum_attainable_score_summed_per_category = scheme_criteria_per_category.values.collect { |sc_cat|
      sc_cat.collect { |sc| sc.weighted_minimum_attainable_score}.inject(:+)
    }
    weighted_minimum_attainable_score_summed_per_category.min
  end
end
