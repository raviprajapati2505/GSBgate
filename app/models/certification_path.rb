class CertificationPath < ActiveRecord::Base
  belongs_to :project
  belongs_to :certificate
  has_many :scheme_mixes
  has_many :schemes, through: :scheme_mixes

  enum status: [ :registered ]

end
