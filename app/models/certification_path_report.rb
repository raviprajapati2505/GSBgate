class CertificationPathReport < ApplicationRecord
  belongs_to :certification_path

  # validates :to, :reference_number, :project_owner, :project_name, :project_location, :issuance_date, :approval_date, presence: true

  after_update :delete_all_tasks, if: -> { is_released? }  

  def self.attributes_for_user(role)
    case role
    when 'default_role'
      [:to, :project_owner, :project_name, :project_location]
    when 'system_admin', 'gsas_trust_admin', 'document_controller'
      [:to, :reference_number, :project_owner, :project_name, :project_location]
    end
  end

  private
  
    # delete all certification assciated tasks.
    def delete_all_tasks
      Task.where(certification_path_id: certification_path_id).delete_all
    end

end
