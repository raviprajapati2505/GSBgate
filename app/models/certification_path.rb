class CertificationPath < ActiveRecord::Base
  belongs_to :project
  has_many :scheme_mixes
end
