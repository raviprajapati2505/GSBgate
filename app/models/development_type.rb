class DevelopmentType < ApplicationRecord
  belongs_to :certificate, optional: true
  has_many :development_type_schemes, dependent: :destroy
  has_many :schemes, through: :development_type_schemes
end
