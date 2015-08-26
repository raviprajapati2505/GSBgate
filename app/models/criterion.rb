class Criterion < ActiveResource
  belongs_to :category
  has_many :scheme_criterions
end
