class CertificationPath < ActiveRecord::Base
  belongs_to :project
  belongs_to :certification_path_status
  has_many :scheme_mixes
end
