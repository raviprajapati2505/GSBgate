class RenameConstructionCertificate < ActiveRecord::Migration
  def up
    construction_certificate = Certificate.find_by(certificate_type: Certificate.certificate_types[:construction_type], assessment_stage: Certificate.assessment_stages[:construction_stage])
    construction_certificate.name = 'Construction Management Certificate'
    construction_certificate.save!
  end

  def down
    construction_certificate = Certificate.find_by(certificate_type: Certificate.certificate_types[:construction_type], assessment_stage: Certificate.assessment_stages[:construction_stage])
    construction_certificate.name = 'Construction Certificate'
    construction_certificate.save!
  end
end
