class SchemeMix < ActiveRecord::Base
  belongs_to :certification_path
  belongs_to :scheme
  has_many :scheme_mix_criteria
end
