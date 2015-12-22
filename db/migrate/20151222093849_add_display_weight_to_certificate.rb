class AddDisplayWeightToCertificate < ActiveRecord::Migration
  def up
    add_column :certificates, :display_weight, :integer

    loc_certificate = Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:design_stage])
    loc_certificate.display_weight = 10
    loc_certificate.save!

    final_design_certificate = Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:construction_stage])
    final_design_certificate.display_weight = 20
    final_design_certificate.save!

    construction_certificate = Certificate.find_by(certificate_type: Certificate.certificate_types[:construction_type], assessment_stage: Certificate.assessment_stages[:construction_stage])
    construction_certificate.display_weight = 30
    construction_certificate.save!

    operations_certificate = Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage])
    operations_certificate.display_weight = 40
    operations_certificate.save!
  end

  def down
    remove_column :certificates, :display_weight
  end
end
