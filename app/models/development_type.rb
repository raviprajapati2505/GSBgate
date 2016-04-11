class DevelopmentType < ActiveRecord::Base
  belongs_to :certificate
  has_many :development_type_schemes
  has_many :schemes, through: :development_type_schemes
end
