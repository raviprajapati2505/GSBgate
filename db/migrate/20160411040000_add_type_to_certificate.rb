class AddTypeToCertificate < ActiveRecord::Migration
  def up
    add_column :certificates, :certification_type, :integer
    Certificate.where(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:design_stage]).update_all(certification_type: Certificate.certification_types[:letter_of_conformance])
    Certificate.where(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:construction_stage]).update_all(certification_type: Certificate.certification_types[:final_design_certificate])
    Certificate.where(certificate_type: Certificate.certificate_types[:construction_type]).update_all(certification_type: Certificate.certification_types[:construction_certificate])
    Certificate.where(certificate_type: Certificate.certificate_types[:operations_type]).update_all(certification_type: Certificate.certification_types[:operations_certificate])
  end
  def down
    remove_column :certificates, :certification_type
  end
end
