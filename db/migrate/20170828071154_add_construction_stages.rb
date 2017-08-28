class AddConstructionStages < ActiveRecord::Migration
  def change
    # Rename old Construction 2.1 issue 1 certificate from 'Construction Certificate' to 'Construction Certificate (foundation stage:1)'
    Certificate.where(certification_type: 30, gsas_version: '2.1 issue 1').update_all(name: 'Construction Certificate (foundation stage:1)', display_weight: 31, certification_type: Certificate.certification_types[:construction_certificate_stage1])
    stage2 = Certificate.new(name: 'Construction Certificate (sub- and superstructure stage:2', certificate_type: Certificate.certificate_types[:construction_type], assessment_stage: Certificate.assessment_stages[:construction_stage], display_weight: 32, gsas_version: '2.1 issue 1', certification_type: Certificate.certification_types[:construction_certificate_stage2])
    stage2.save!
    stage3 = Certificate.new(name: 'Construction Certificate (finishing stage:3)', certificate_type: Certificate.certificate_types[:construction_type], assessment_stage: Certificate.assessment_stages[:construction_stage], display_weight: 33, gsas_version: '2.1 issue 1', certification_type: Certificate.certification_types[:construction_certificate_stage3])
    stage3.save!

    # Add new development types for the new construction stages
    dev_type2 = DevelopmentType.new(certificate: stage2, name: 'Single use construction', display_weight: 10, mixable: false)
    dev_type2.save!
    dev_type3 = DevelopmentType.new(certificate: stage3, name: 'Single use construction', display_weight: 10, mixable: false)
    dev_type3.save!

    # Link new development types to existing schemes
    dev_type_scheme2 = DevelopmentTypeScheme.new(development_type: dev_type2, scheme_id: Scheme.find_by(name: 'Construction').id)
    dev_type_scheme2.save!
    dev_type_scheme3 = DevelopmentTypeScheme.new(development_type: dev_type3, scheme_id: Scheme.find_by(name: 'Construction').id)
    dev_type_scheme3.save!
  end
end
