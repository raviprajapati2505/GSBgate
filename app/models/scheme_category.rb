class SchemeCategory < ActiveRecord::Base
  has_many :scheme_criteria
  belongs_to :scheme
  default_scope { order(name: :asc) }
end
