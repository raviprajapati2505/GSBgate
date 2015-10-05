# ruby encoding: utf-8
# Custom criteria for release 1
Scheme.create!(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage]))

SchemeCategory.create!(scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage])), code: "E", name: "Energy (existing buildings)", description: "<p>Energy TODO</p>", impacts: "<p>Impacts TODO</p>", mitigate_impact: "<p>Mitigate Impact TODO</p>")
SchemeCategory.create!(scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage])), code: "W", name: "Water (existing buildings)", description: "<p>Water TODO</p>", impacts: "<p>Impacts TODO</p>", mitigate_impact: "<p>Mitigate Impact TODO</p>")

SchemeCriterion.create!(name: "Energy Conservation", number: 1, scores: [0, 1], weight: 60, scheme_category: SchemeCategory.find_by(code: "E", scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage]))))
SchemeCriterion.create!(name: "Water Conservation", number: 1, scores: [0, 1], weight: 40, scheme_category: SchemeCategory.find_by(code: "W", scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage]))))

SchemeCriterionText.create!(scheme_criterion: SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "E", scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage]))), name: "Energy Consumption"), name: "SCORE", display_weight: 1, visible: true, html_text: "<p>SCORE TODO</p>")
SchemeCriterionText.create!(scheme_criterion: SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "W", scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage]))), name: "Water Consumption"), name: "SCORE", display_weight: 1, visible: true, html_text: "<p>SCORE TODO</p>")

# Incentive Weights
SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "S", scheme: Scheme.find_by(name: "Healthcare", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:design_stage]))), name: "GSAS Construction Management - Full").update_attributes(:incentive_weight => 1.0)
SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "S", scheme: Scheme.find_by(name: "Healthcare", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:construction_stage]))), name: "GSAS Construction Management - Full").update_attributes(:incentive_weight => 1.0)
SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "M", scheme: Scheme.find_by(name: "Healthcare", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:design_stage]))), name: "Life Cycle Assessment (LCA)").update_attributes(:incentive_weight => 2.0)
SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "M", scheme: Scheme.find_by(name: "Healthcare", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:construction_stage]))), name: "Life Cycle Assessment (LCA)").update_attributes(:incentive_weight => 2.0)
SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "MO", scheme: Scheme.find_by(name: "Healthcare", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:design_stage]))), name: "Energy & Water Use Sub-metering").update_attributes(:incentive_weight => 1.0)
SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "MO", scheme: Scheme.find_by(name: "Healthcare", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:construction_stage]))), name: "Energy & Water Use Sub-metering").update_attributes(:incentive_weight => 1.0)

SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "S", scheme: Scheme.find_by(name: "Sports", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:design_stage]))), name: "GSAS Construction Management - Full").update_attributes(:incentive_weight => 1.0)
SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "S", scheme: Scheme.find_by(name: "Sports", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:construction_stage]))), name: "GSAS Construction Management - Full").update_attributes(:incentive_weight => 1.0)
SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "M", scheme: Scheme.find_by(name: "Sports", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:design_stage]))), name: "Life Cycle Assessment (LCA)").update_attributes(:incentive_weight => 2.0)
SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "M", scheme: Scheme.find_by(name: "Sports", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:construction_stage]))), name: "Life Cycle Assessment (LCA)").update_attributes(:incentive_weight => 2.0)
SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "MO", scheme: Scheme.find_by(name: "Sports", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:design_stage]))), name: "Energy & Water Use Sub-metering").update_attributes(:incentive_weight => 1.0)
SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "MO", scheme: Scheme.find_by(name: "Sports", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:construction_stage]))), name: "Energy & Water Use Sub-metering").update_attributes(:incentive_weight => 1.0)

SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "S", scheme: Scheme.find_by(name: "Railways", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:design_stage]))), name: "GSAS Construction Management - Full").update_attributes(:incentive_weight => 1.0)
SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "S", scheme: Scheme.find_by(name: "Railways", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:construction_stage]))), name: "GSAS Construction Management - Full").update_attributes(:incentive_weight => 1.0)
SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "M", scheme: Scheme.find_by(name: "Railways", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:design_stage]))), name: "Life Cycle Assessment (LCA)").update_attributes(:incentive_weight => 2.0)
SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "M", scheme: Scheme.find_by(name: "Railways", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:construction_stage]))), name: "Life Cycle Assessment (LCA)").update_attributes(:incentive_weight => 2.0)
SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "MO", scheme: Scheme.find_by(name: "Railways", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:design_stage]))), name: "Energy & Water Use Sub-metering").update_attributes(:incentive_weight => 1.0)
SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "MO", scheme: Scheme.find_by(name: "Railways", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:construction_stage]))), name: "Energy & Water Use Sub-metering").update_attributes(:incentive_weight => 1.0)

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

CertificationPathStatus.create!(id: CertificationPathStatus::ACTIVATING, name: 'Activating', past_name: 'Activated', context: CertificationPathStatus.contexts[:gord_team], description: 'The certificate is created. After payment is received, a GSAS administrator will advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::SUBMITTING, name: 'Submitting', past_name: 'Submitted', context: CertificationPathStatus.contexts[:project_team], description: 'The certificate is activated by a GSAS administrator. The project team can now provide the requirements for all criteria and set the submitted scores of all criteria. When all criteria are completed, a project team manager will advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::SCREENING, name: 'Screening', past_name: 'Screened', context: CertificationPathStatus.contexts[:gord_team], description: 'The project team has completed all criteria. After the GORD certifier team has screened the criteria input, a GORD certifier manager will advance the status of the certificate and provide screening comments.')
CertificationPathStatus.create!(id: CertificationPathStatus::SUBMITTING_AFTER_SCREENING, name: 'Submitting after screening', past_name: 'Submitted after screening', context: CertificationPathStatus.contexts[:project_team], description: 'The GORD certifier team has screened and commented the criteria input. The project team can process this feedback by editing the existing criteria input. When all criteria are completed, a project team manager will advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::PROCESSING_PCR_PAYMENT, name: 'Processing PCR payment', past_name: 'PCR payment processed', context: CertificationPathStatus.contexts[:gord_team], description: 'A Pre Certification Review (PCR) was requested. After payment is received, a GSAS administrator will advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::SUBMITTING_PCR, name: 'Submitting PCR', past_name: 'PCR submitted', context: CertificationPathStatus.contexts[:project_team], description: 'A Pre Certification Review (PCR) is in progress. When all criteria are completed, a project team manager will advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::VERIFYING, name: 'Verifying', past_name: 'Verified', context: CertificationPathStatus.contexts[:gord_team], description: 'The project team has completed all criteria. The GORD certifier team will now review all criteria input and set the the achieved scores of the criteria. After all criteria are approved or disapproved, a GORD certifier manager will advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::ACKNOWLEDGING, name: 'Acknowledging', past_name: 'Acknowledged', context: CertificationPathStatus.contexts[:project_team], description: 'The GORD certifier team has verified all criteria. After a project team manager acknowledges the achieved scores, he will advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::PROCESSING_APPEAL_PAYMENT, name: 'Processing appeal payment', past_name: 'Appeal payment processed', context: CertificationPathStatus.contexts[:gord_team], description: 'An appeal was requested by a project team manager. After payment is received, a GSAS administrator will advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::SUBMITTING_AFTER_APPEAL, name: 'Submitting after appeal', past_name: 'Submitted after appeal', context: CertificationPathStatus.contexts[:project_team], description: 'An appeal was requested by a project team manager. The project team can now (re)provide the requirements for all criteria and set the submitted scores of all criteria. When all criteria are completed, a project team manager can advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::VERIFYING_AFTER_APPEAL, name: 'Verifying after appeal', past_name: 'Verified after appeal', context: CertificationPathStatus.contexts[:gord_team], description: 'The project team has completed all criteria. The GORD certifier team will now review all criteria input and set the the achieved scores of the criteria. After all criteria are approved or disapproved, a GORD certifier manager will advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL, name: 'Acknowledging after appeal', past_name: 'Acknowledged after appeal', context: CertificationPathStatus.contexts[:project_team], description: 'The GORD certifier team has verified all criteria. After a project team manager acknowledges the achieved scores, he will advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::APPROVING_BY_MANAGEMENT, name: 'Approving by management', past_name: 'Approved by management', context: CertificationPathStatus.contexts[:gord_team], description: 'The GORD certifier team approved this certificate and a project team manager has requested a certificate. The GORD managers will now sign the certificate and advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::CERTIFIED, name: 'Certified', past_name: 'Certified', context: CertificationPathStatus.contexts[:gord_team], description: 'GORD has issued a certificate for this certificate. The certificate can be downloaded.')
CertificationPathStatus.create!(id: CertificationPathStatus::NOT_CERTIFIED, name: 'Not certified', past_name: 'Not certified', context: CertificationPathStatus.contexts[:gord_team], description: 'GORD has denied a certificate for this certificate.')