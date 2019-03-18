class Field < ApplicationRecord
  has_many :field_data
  belongs_to :calculator, optional: true
end
