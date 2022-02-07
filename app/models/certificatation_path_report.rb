class CertificatationPathReport < ApplicationRecord
  belongs_to :certification_path

  validates :to, :reference_number, :project_owner, :project_name, :project_location, :issuance_date, :approval_date, presence: true

  def check_values_present?
    reference_number.present?
  end
end
