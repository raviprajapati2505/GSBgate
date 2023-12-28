class CertificationPathReport < ApplicationRecord
  include Taskable

  belongs_to :certification_path

  # validates :to, :reference_number, :project_owner, :project_name, :project_location, :issuance_date, :approval_date, presence: true

  def self.attributes_for_user(role)
    case role
    when 'default_role'
      [:to, :project_owner, :project_name, :project_location]
    when 'system_admin', 'gsas_trust_admin', 'document_controller'
      [:to, :reference_number, :project_owner, :project_name, :project_location]
    end
  end
end
