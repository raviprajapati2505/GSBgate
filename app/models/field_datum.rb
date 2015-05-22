class FieldDatum < ActiveRecord::Base
  has_many :requirement_data, as: :reportable_data
  belongs_to :field
end
