class SchemeMixCriterion < ActiveRecord::Base
  has_many :scheme_mix_criteria_requirement_data
  has_many :requirement_data, through: :scheme_mix_criteria_requirement_data
  belongs_to :scheme_mix
  belongs_to :scheme_criterion
end
