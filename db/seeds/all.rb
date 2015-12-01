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
["Healthcare", "Sports", "Railways"].each do |scheme|
  [{:code => "S", :name => "GSAS Construction Management - Full", :incentive => 1.0},
   {:code => "M", :name => "Life Cycle Assessment (LCA)", :incentive => 2.0},
   {:code => "MO", :name => "Energy & Water Use Sub-metering", :incentive => 1.0}
  ].each do |incentive_criteria|
    loc_criterion = SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: incentive_criteria[:code], scheme: Scheme.find_by(name: scheme, version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:design_stage]))), name: incentive_criteria[:name])
    loc_criterion.update_attributes(:incentive_weight => incentive_criteria[:incentive], :weight => loc_criterion.weight - incentive_criteria[:incentive])
    final_criterion = SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: incentive_criteria[:code], scheme: Scheme.find_by(name: scheme, version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:construction_stage]))), name: incentive_criteria[:name])
    final_criterion.update_attributes(:incentive_weight => incentive_criteria[:incentive], :weight => final_criterion.weight - incentive_criteria[:incentive])
  end
end

ec1 = Calculator.create!(name: 'Calculator::Dummy')
wc1 = Calculator.create!(name: 'Calculator::Dummy')
req1 = Requirement.create!(calculator: ec1, name: 'Energy calculator')
req2 = Requirement.create!(calculator: wc1, name: 'Water calculator')
req3 = Requirement.create!(name: 'Specifications and documentation regarding the available infrastructure showing that the existing structures can handle the additional load from the building')
req4 = Requirement.create!(name: 'Ground plan')
req5 = Requirement.create!(name: 'Ventilation plan')
SchemeCriteriaRequirement.create!(scheme_criterion: SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "E", scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage])))), requirement: req1)
SchemeCriteriaRequirement.create!(scheme_criterion: SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "W", scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage])))), requirement: req2)
SchemeCriteriaRequirement.create!(scheme_criterion: SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "E", scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage])))), requirement: req3)
SchemeCriteriaRequirement.create!(scheme_criterion: SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "W", scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage])))), requirement: req4)
SchemeCriteriaRequirement.create!(scheme_criterion: SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: "E", scheme: Scheme.find_by(name: "Operations", version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage])))), requirement: req5)
Field.create!(name: 'Yearly energy usage', machine_name: 'kwh_year', calculator: ec1, datum_type: 'FieldDatum::IntegerValue')
Field.create!(name: 'Yearly water usage', machine_name: 'l_year', suffix: 'liter', help_text: 'Please provide the yearly water usage in liter.', calculator: wc1, datum_type: 'FieldDatum::IntegerValue')

CertificationPathStatus.create!(id: CertificationPathStatus::ACTIVATING, name: 'Activating', past_name: 'Activated', description: 'The certificate is created. After payment is received, a GSAS administrator will advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::SUBMITTING, name: 'Submitting', past_name: 'Submitted', description: 'The certificate is activated by a GSAS administrator. The project team can now provide the requirements for all criteria and set the submitted scores of all criteria. When all criteria are completed, a project team manager will advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::SCREENING, name: 'Screening', past_name: 'Screened', description: 'The project team has completed all criteria. After the GORD certifier team has screened the criteria input, a GORD certifier manager will advance the status of the certificate and provide screening comments.')
CertificationPathStatus.create!(id: CertificationPathStatus::SUBMITTING_AFTER_SCREENING, name: 'Submitting after screening', past_name: 'Submitted after screening', description: 'The GORD certifier team has screened and commented the criteria input. The project team can process this feedback by editing the existing criteria input. When all criteria are completed, a project team manager will advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::PROCESSING_PCR_PAYMENT, name: 'Processing PCR payment', past_name: 'PCR payment processed', description: 'A Pre Certification Review (PCR) was requested. After payment is received, a GSAS administrator will advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::SUBMITTING_PCR, name: 'Submitting PCR', past_name: 'PCR submitted', description: 'A Pre Certification Review (PCR) is in progress. When all criteria are completed, a project team manager will advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::VERIFYING, name: 'Verifying', past_name: 'Verified', description: 'The project team has completed all criteria. The GORD certifier team will now review all criteria input and set the the achieved scores of the criteria. After all criteria are approved or disapproved, a GORD certifier manager will advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::ACKNOWLEDGING, name: 'Acknowledging', past_name: 'Acknowledged', description: 'The GORD certifier team has verified all criteria. A project team manager must now chose to accept all scores or apply for appeal. After this, the certificate status will be advanced.')
CertificationPathStatus.create!(id: CertificationPathStatus::PROCESSING_APPEAL_PAYMENT, name: 'Processing appeal payment', past_name: 'Appeal payment processed', description: 'An appeal was requested by a project team manager. After payment is received, a GSAS administrator will advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::SUBMITTING_AFTER_APPEAL, name: 'Submitting after appeal', past_name: 'Submitted after appeal', description: 'An appeal was requested by a project team manager. The project team can now (re)provide the requirements for all criteria and set the submitted scores of all criteria. When all criteria are completed, a project team manager can advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::VERIFYING_AFTER_APPEAL, name: 'Verifying after appeal', past_name: 'Verified after appeal', description: 'The project team has completed all criteria. The GORD certifier team will now review all criteria input and set the the achieved scores of the criteria. After all criteria are approved or disapproved, a GORD certifier manager will advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL, name: 'Acknowledging after appeal', past_name: 'Acknowledged after appeal', description: 'The GORD certifier team has verified all criteria. After a project team manager acknowledges the achieved scores, he will advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::APPROVING_BY_MANAGEMENT, name: 'Approving by management', past_name: 'Approved by management', description: 'The GORD certifier team approved this certificate. The GORD management will now give their approval and advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT, name: 'Approving by top management', past_name: 'Approved by top management', description: 'The GORD management approved this certificate. The GORD top management will now give their approval and advance the status of the certificate.')
CertificationPathStatus.create!(id: CertificationPathStatus::CERTIFIED, name: 'Certified', past_name: 'Certified', description: 'GORD has issued this certificate, it can now be downloaded.')
CertificationPathStatus.create!(id: CertificationPathStatus::NOT_CERTIFIED, name: 'Not certified', past_name: 'Not certified', description: 'GORD has denied this certificate.')

NotificationType.create!(id: NotificationType::NEW_USER_COMMENT, name: 'New user comment', project_level: true)
NotificationType.create!(id: NotificationType::PROJECT_CREATED, name: 'Project created', project_level: false)
NotificationType.create!(id: NotificationType::CERTIFICATE_APPLIED, name: 'Certificate applied', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_ACTIVATED, name: 'Certificate activated', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_SUBMITTED_FOR_SCREENING, name: 'Certificate submitted for screening', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_SCREENED, name: 'Certificate screened', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_PCR_SELECTED, name: 'PCR for Certificate selected', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_PCR_APPROVED, name: 'PCR for Certificate approved', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_SUBMITTED_FOR_VERIFICATION, name: 'Certificate submitted for verification', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_VERIFIED, name: 'Certificate verified', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_APPEALED, name: 'Some criteria of Certificate are appealed', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_APPEAL_APPROVED, name: 'Certificate criteria appeal approved', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_SUBMITTED_FOR_VERIFICATION_AFTER_APPEAL, name: 'Certificate submitted after appeal', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_VERIFIED_AFTER_APPEAL, name: 'Certificate verified after appeal', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_APPROVED_BY_MNGT, name: 'Certificate approved by GORD management', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_ISSUED, name: 'Certificate issued', project_level: true)
NotificationType.create!(id: NotificationType::CRITERION_SUBMITTED, name: 'Criterion submitted', project_level: true)
NotificationType.create!(id: NotificationType::CRITERION_VERIFIED, name: 'Criterion verified', project_level: true)
NotificationType.create!(id: NotificationType::CRITERION_APPEALED, name: 'Criterion appealed', project_level: true)
NotificationType.create!(id: NotificationType::CRITERION_SUBMITTED_AFTER_APPEAL, name: 'Criterion submitted after appeal', project_level: true)
NotificationType.create!(id: NotificationType::CRITERION_VERIFIED_AFTER_APPEAL, name: 'Criterion verified after appeal', project_level: true)
NotificationType.create!(id: NotificationType::REQUIREMENT_PROVIDED, name: 'Requirement provided', project_level: true)
NotificationType.create!(id: NotificationType::NEW_DOCUMENT_WAITING_FOR_APPROVAL, name: 'New document uploaded for criterion', project_level: true)
NotificationType.create!(id: NotificationType::DOCUMENT_APPROVED, name: 'Document approved', project_level: true)
NotificationType.create!(id: NotificationType::NEW_TASK, name: 'New task', project_level: false)
