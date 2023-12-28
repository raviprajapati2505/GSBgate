class InsertOverallConstructionCertificate < ActiveRecord::Migration[4.2]
  def change
    overall_construction_certificate = Certificate.new(name: 'Construction Certificate', certificate_type: Certificate.certificate_types[:construction_type], assessment_stage: Certificate.assessment_stages[:construction_stage], display_weight: 39, gsas_version: '2.1 issue 1', certification_type: Certificate.certification_types[:construction_certificate])
    overall_construction_certificate.save!

    dev_type = DevelopmentType.new(certificate: overall_construction_certificate, name: 'Single use construction', display_weight: 10, mixable: false)
    dev_type.save!

    scheme = Scheme.new(name: 'Construction', gsas_version: '2.1', renovation: false, gsas_document: 'Construction GSAS Assessment & Guideline v2.1.html', certificate_type: Certificate.certificate_types[:construction_type])
    scheme.save!

    dev_type_scheme = DevelopmentTypeScheme.new(development_type: dev_type, scheme: scheme)
    dev_type_scheme.save!

    scheme_category = SchemeCategory.new(name: 'GSAS Construction Internal', scheme: scheme, shared: false)
    scheme_category.save!

    change_column :scheme_criteria, :minimum_score, :decimal, precision: 4, scale: 1
    change_column :scheme_criteria, :maximum_score, :decimal, precision: 4, scale: 1
    change_column :scheme_criteria, :minimum_valid_score, :decimal, precision: 4, scale: 1

    change_column :scheme_mix_criteria, :targeted_score, :decimal, precision: 4, scale: 1
    change_column :scheme_mix_criteria, :submitted_score, :decimal, precision: 4, scale: 1
    change_column :scheme_mix_criteria, :achieved_score, :decimal, precision: 4, scale: 1

    scheme_criterion = SchemeCriterion.new(weight: 100, name: 'GSAS Construction Internal', scheme_category: scheme_category, minimum_score: 0.0, maximum_score: 100.0, minimum_valid_score: 0.0)
    scheme_criterion.save!
  end
end
