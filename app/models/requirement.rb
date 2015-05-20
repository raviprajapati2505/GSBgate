class Requirement < ActiveRecord::Base
  has_many :scheme_criterion_requirements
  has_many :scheme_criteria, through: :scheme_criterion_requirements
  belongs_to :reportable, polymorphic: true
end
