class CertificationPath < ActiveRecord::Base
  belongs_to :project
  belongs_to :certification_path_status
  belongs_to :certificate
  has_many :scheme_mixes
end
