class Calculator < ActiveRecord::Base
  has_many :requirements
  has_many :fields
  has_many :calculator_data
end