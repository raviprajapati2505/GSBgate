class SchemeMix < ActiveRecord::Base
  belongs_to :certification_path
  belongs_to :scheme
end
