class Calculator < ActiveRecord::Base
  has_many :requirements, as: :reportable
  has_many :fields
  has_many :calculator_data
end