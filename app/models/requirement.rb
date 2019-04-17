class Requirement < ApplicationRecord
  include Auditable

  has_many :scheme_criteria_requirements
  has_many :scheme_criteria, through: :scheme_criteria_requirements
  has_many :requirement_data
  belongs_to :calculator, optional: true
end
