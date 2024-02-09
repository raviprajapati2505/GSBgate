class Calculator < ApplicationRecord
  has_many :requirements, dependent: :destroy
  has_many :fields, dependent: :destroy
  has_many :calculator_data, dependent: :destroy
end