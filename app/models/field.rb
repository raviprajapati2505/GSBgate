class Field < ActiveResource
  has_many :field_data
  belongs_to :calculator
end
