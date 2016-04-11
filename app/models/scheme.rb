class Scheme < ActiveRecord::Base
  has_many :development_type_scheme
  has_many :development_types, through: :development_type_schemes
  has_many :scheme_categories
  has_many :scheme_criteria, through: :scheme_categories
  has_many :scheme_mixes
  has_many :scheme_mix_criteria, through: :scheme_mixes
  has_many :certification_paths, through: :scheme_mixes

  def full_name
    "GSAS #{Certificate.human_attribute_name(self.certificate.assessment_stage)} Assessment v#{gsas_version}: #{name}"
  end

  # sums the weights for all scheme_criteria belonging to the given category
  def weight_for_category(category)
    scheme_criteria.for_category(category).sum(:weight)
  end

  def incentive_weight_for_category(category)
    scheme_criteria.for_category(category).sum(:incentive_weight)
  end
end
