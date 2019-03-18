class Calculator < ApplicationRecord
  has_many :requirements
  has_many :fields
  has_many :calculator_data
end