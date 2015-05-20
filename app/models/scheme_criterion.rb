class SchemeCriterion < ActiveRecord::Base
  belongs_to :scheme
  belongs_to :criterion
  has_many :scores
  has_many :scheme_mix_criteria
end
