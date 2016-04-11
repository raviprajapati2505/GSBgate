class DevelopmentTypeScheme < ActiveRecord::Base
  belongs_to :development_type
  belongs_to :scheme
end
