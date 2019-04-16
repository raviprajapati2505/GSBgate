class DevelopmentTypeScheme < ApplicationRecord
  belongs_to :development_type, optional: true
  belongs_to :scheme, optional: true
end
