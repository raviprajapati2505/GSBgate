class SchemeCriterion < ActiveRecord::Base
  belongs_to :scheme
  belongs_to :criterion
  has_many :scores
end
