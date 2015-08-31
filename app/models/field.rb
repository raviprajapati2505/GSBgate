class Field < ActiveRecord::Base
  has_many :field_data
  belongs_to :calculator
end
