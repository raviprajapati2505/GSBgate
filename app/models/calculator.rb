class Calculator < ActiveResource
  has_many :requirements
  has_many :fields
  has_many :calculator_data
end