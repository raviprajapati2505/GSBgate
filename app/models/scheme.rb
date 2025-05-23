class Scheme < ApplicationRecord
  include Auditable

  has_many :development_type_schemes, dependent: :destroy
  has_many :development_types, through: :development_type_schemes
  has_many :scheme_categories, dependent: :destroy
  has_many :scheme_criteria, through: :scheme_categories
  has_many :scheme_mixes
  has_many :scheme_mix_criteria, through: :scheme_mixes
  has_many :certification_paths, through: :scheme_mixes

  def full_name
    # "GSB #{name} v#{gsb_version}"
    name
  end

  # sums the weights for all scheme_criteria belonging to the given category
  def weight_for_category(category)
    scheme_criteria.for_category(category).sum(SchemeCriterion::WEIGHT_ATTRIBUTES.join(' + '))
  end
end
