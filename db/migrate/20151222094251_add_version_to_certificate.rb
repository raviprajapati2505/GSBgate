class AddVersionToCertificate < ActiveRecord::Migration
  def change
    add_column :certificates, :version, :string
  end

  def up
    loc_certificate = Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:design_stage])
    loc_certificate.version = '2.1'
    loc_certificate.save!

    final_design_certificate = Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:construction_stage])
    final_design_certificate.version = '2.1'
    final_design_certificate.save!

    construction_certificate = Certificate.find_by(certificate_type: Certificate.certificate_types[:construction_type], assessment_stage: Certificate.assessment_stages[:construction_stage])
    construction_certificate.version = '2.1'
    construction_certificate.save!

    operations_certificate = Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage])
    operations_certificate.version = '2.1'
    operations_certificate.save!
  end

end
