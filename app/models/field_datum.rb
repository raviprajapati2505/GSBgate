class FieldDatum < ActiveRecord::Base
  belongs_to :calculator_datum
  belongs_to :field
end
