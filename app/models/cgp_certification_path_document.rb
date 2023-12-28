class CgpCertificationPathDocument < CertificationPathDocument
  include Auditable
  include Taskable
  belongs_to :certification_path_status, optional: true

  after_create :set_certification_status

  private

  def set_certification_status
    self.update_column(:certification_path_status_id, certification_path&.certification_path_status_id)
  end
end