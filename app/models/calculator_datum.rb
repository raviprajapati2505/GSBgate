class CalculatorDatum < ActiveRecord::Base
  has_many :requirement_data, as: :reportable_data
  has_many :field_data
  belongs_to :calculator
end
