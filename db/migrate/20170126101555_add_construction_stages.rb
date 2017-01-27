class AddConstructionStages < ActiveRecord::Migration
  def change
    Certificate.where(certification_type: Certificate.certification_types[:construction_certificate]).update_all(name: 'Construction Certificate (foundation stage:1)', display_weight: 31)
    stage2 = Certificate.new(name: 'Construction Certificate (sub- and superstructure stage:2)', certificate_type: Certificate.certificate_types[:construction_type], assessment_stage: Certificate.assessment_stages[:construction_stage], display_weight: 32, gsas_version: '2.1 issue 1', certification_type: Certificate.certification_types[:construction_certificate])
    stage2.save!
    stage3 = Certificate.new(name: 'Construction Certificate (finishing stage:3)', certificate_type: Certificate.certificate_types[:construction_type], assessment_stage: Certificate.assessment_stages[:construction_stage], display_weight: 33, gsas_version: '2.1 issue 1', certification_type: Certificate.certification_types[:construction_certificate])
    stage3.save!

    dev_type2 = DevelopmentType.new(certificate: stage2, name: 'Single use construction', display_weight: 10, mixable: false)
    dev_type2.save!
    dev_type3 = DevelopmentType.new(certificate: stage3, name: 'Single use construction', display_weight: 10, mixable: false)
    dev_type3.save!

    dev_type_schemes2 = DevelopmentTypeScheme.new(development_type: dev_type2, scheme_id: Scheme.find_by(name: 'Construction'))
    dev_type_schemes2.save!
    dev_type_scheme3 = DevelopmentTypeScheme.new(development_type: dev_type3, scheme_id: Scheme.find_by(name: 'Construction'))
    dev_type_scheme3.save!
  end
end
