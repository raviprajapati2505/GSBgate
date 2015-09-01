# ruby encoding: utf-8
# Custom criteria for release 1
Scheme.create!(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage]))

SchemeCategory.create!(scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage])), code: "E", name: "Energy (existing buildings)", description: "<p>Energy TODO</p>", impacts: "<p>Impacts TODO</p>", mitigate_impact: "<p>Mitigate Impact TODO</p>")
SchemeCategory.create!(scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage])), code: "W", name: "Water (existing buildings)", description: "<p>Water TODO</p>", impacts: "<p>Impacts TODO</p>", mitigate_impact: "<p>Mitigate Impact TODO</p>")

SchemeCriterion.create!(name: "Energy Conservation", number: 1, scores: [0, 1], weight: 60, scheme_category: SchemeCategory.find_by(code: "E", scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage]))))
SchemeCriterion.create!(name: "Water Conservation", number: 1, scores: [0, 1], weight: 40, scheme_category: SchemeCategory.find_by(code: "W", scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage]))))

SchemeCriterionText.create!(scheme_criterion: SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "E", scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage]))), name: "Energy Consumption"), name: "SCORE", display_weight: 1, visible: true, html_text: "<p>SCORE TODO</p>")
SchemeCriterionText.create!(scheme_criterion: SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "W", scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage]))), name: "Water Consumption"), name: "SCORE", display_weight: 1, visible: true, html_text: "<p>SCORE TODO</p>")


ec1 = Calculator.create!(name: 'Calculator::Dummy')
wc1 = Calculator.create!(name: 'Calculator::Dummy')
req1 = Requirement.create!(calculator: ec1, name: 'Energy calculator')
req2 = Requirement.create!(calculator: wc1, name: 'Water calculator')
req3 = Requirement.create!(name: 'Specifications and documentation regarding the available infrastructure showing that the existing structures can handle the additional load from the building')
SchemeCriteriaRequirement.create!(scheme_criterion: SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "E", scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage])))), requirement: req1)
SchemeCriteriaRequirement.create!(scheme_criterion: SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "W", scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage])))), requirement: req2)
SchemeCriteriaRequirement.create!(scheme_criterion: SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "E", scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage])))), requirement: req3)
Field.create!(name: 'Yearly energy usage', machine_name: 'kwh_year', calculator: ec1, datum_type: 'FieldDatum::IntegerValue')
Field.create!(name: 'Yearly water usage', machine_name: 'l_year', suffix: 'liter', help_text: 'Please provide the yearly water usage in liter.', calculator: wc1, datum_type: 'FieldDatum::IntegerValue')
