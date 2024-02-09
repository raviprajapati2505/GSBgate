class CalculatorDatum < ApplicationRecord
  has_many :requirement_data, dependent: :destroy
  has_many :field_data, dependent: :destroy
  belongs_to :calculator, optional: true
end
