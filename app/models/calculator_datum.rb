class CalculatorDatum < ApplicationRecord
  has_many :requirement_data
  has_many :field_data, dependent: :destroy
  belongs_to :calculator, optional: true
end
