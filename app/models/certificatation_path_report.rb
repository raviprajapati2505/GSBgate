class CertificatationPathReport < ApplicationRecord
  belongs_to :certification_path

  validates :to, :reference_number, :project_owner, :service_provider, :project_name, :project_location, :issuance_date, :approval_date, presence: true
end
