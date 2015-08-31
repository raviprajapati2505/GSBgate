class Criterion < ActiveRecord::Base
  belongs_to :category
  has_many :scheme_criterions
end
