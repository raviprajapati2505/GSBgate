# ruby encoding: utf-8
# Incentive Weights
["Healthcare", "Sports", "Railways"].each do |scheme|
  [{:code => "S", :name => "GSAS Construction Management - Full", :incentive => 1.0},
   {:code => "M", :name => "Life Cycle Assessment (LCA)", :incentive => 2.0},
   {:code => "MO", :name => "Energy & Water Use Sub-metering", :incentive => 1.0}
  ].each do |incentive_criteria|
    loc_criterion = SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: incentive_criteria[:code], scheme: Scheme.find_by(name: scheme, gsas_version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:design_stage], gsas_version: "2.1"))), name: incentive_criteria[:name])
    loc_criterion.update_attributes(:incentive_weight => incentive_criteria[:incentive], :weight => loc_criterion.weight - incentive_criteria[:incentive])
    final_criterion = SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: incentive_criteria[:code], scheme: Scheme.find_by(name: scheme, gsas_version: "2.1", certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:construction_stage], gsas_version: "2.1"))), name: incentive_criteria[:name])
    final_criterion.update_attributes(:incentive_weight => incentive_criteria[:incentive], :weight => final_criterion.weight - incentive_criteria[:incentive])
  end
end

# ec1 = Calculator.create!(name: 'Calculator::Dummy')
# wc1 = Calculator.create!(name: 'Calculator::Dummy')
# req1 = Requirement.create!(calculator: ec1, name: 'Energy calculator')
# req2 = Requirement.create!(calculator: wc1, name: 'Water calculator')
# req3 = Requirement.create!(name: 'Specifications and documentation regarding the available infrastructure showing that the existing structures can handle the additional load from the building')
# req4 = Requirement.create!(name: 'Ground plan')
# req5 = Requirement.create!(name: 'Ventilation plan')

CertificationPathStatus.create!(id: CertificationPathStatus::ACTIVATING, name: 'Activating', past_name: 'Activated', description: 'The certification is created. After payment is received, a GSAS administrator will advance the status of the certification.')
CertificationPathStatus.create!(id: CertificationPathStatus::SUBMITTING, name: 'Submitting', past_name: 'Submitted', description: 'The certification is activated by a GSAS administrator. The project team can now provide the requirements for all criteria and set the submitted scores of all criteria. When all criteria are completed, a project team manager will advance the status of the certification.')
CertificationPathStatus.create!(id: CertificationPathStatus::SCREENING, name: 'Screening', past_name: 'Screened', description: 'The project team has completed all criteria. After the GSAS trust team has screened the criteria input, a GORD certifier manager will advance the status of the certification and provide screening comments.')
CertificationPathStatus.create!(id: CertificationPathStatus::SUBMITTING_AFTER_SCREENING, name: 'Submitting after screening', past_name: 'Submitted after screening', description: 'The GSAS trust team has screened and commented the criteria input. The project team can process this feedback by editing the existing criteria input. When all criteria are completed, a project team manager will advance the status of the certification.')
CertificationPathStatus.create!(id: CertificationPathStatus::VERIFYING, name: 'Verifying', past_name: 'Verified', description: 'The project team has completed all criteria. The GSAS trust team will now review all criteria input and set the the achieved scores of the criteria. After all criteria are approved or disapproved, a GORD certifier manager will advance the status of the certification.')
CertificationPathStatus.create!(id: CertificationPathStatus::ACKNOWLEDGING, name: 'Acknowledging', past_name: 'Acknowledged', description: 'The GSAS trust team has verified all criteria. A project team manager must now chose to accept all scores or apply for appeal. After this, the certification status will be advanced.')
CertificationPathStatus.create!(id: CertificationPathStatus::PROCESSING_APPEAL_PAYMENT, name: 'Processing appeal payment', past_name: 'Appeal payment processed', description: 'An appeal was requested by a project team manager. After payment is received, a GSAS administrator will advance the status of the certification.')
CertificationPathStatus.create!(id: CertificationPathStatus::SUBMITTING_AFTER_APPEAL, name: 'Submitting after appeal', past_name: 'Submitted after appeal', description: 'An appeal was requested by a project team manager. The project team can now (re)provide the requirements for all criteria and set the submitted scores of all criteria. When all criteria are completed, a project team manager can advance the status of the certification.')
CertificationPathStatus.create!(id: CertificationPathStatus::VERIFYING_AFTER_APPEAL, name: 'Verifying after appeal', past_name: 'Verified after appeal', description: 'The project team has completed all criteria. The GSAS trust team will now review all criteria input and set the the achieved scores of the criteria. After all criteria are approved or disapproved, a GORD certifier manager will advance the status of the certification.')
CertificationPathStatus.create!(id: CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL, name: 'Acknowledging after appeal', past_name: 'Acknowledged after appeal', description: 'The GSAS trust team has verified all criteria. After a project team manager acknowledges the achieved scores, he will advance the status of the certification.')
CertificationPathStatus.create!(id: CertificationPathStatus::APPROVING_BY_MANAGEMENT, name: 'Approving by management', past_name: 'Approved by management', description: 'The GSAS trust team approved this certification. The GORD management will now give their approval and advance the status of the certification.')
CertificationPathStatus.create!(id: CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT, name: 'Approving by top management', past_name: 'Approved by top management', description: 'The GORD management approved this certification. The GORD top management will now give their approval and advance the status of the certification.')
CertificationPathStatus.create!(id: CertificationPathStatus::CERTIFIED, name: 'Certified', past_name: 'Certified', description: 'GORD has issued this certification, it can now be downloaded.')
CertificationPathStatus.create!(id: CertificationPathStatus::NOT_CERTIFIED, name: 'Not certified', past_name: 'Not certified', description: 'GORD has denied this certification.')

NotificationType.create!(id: NotificationType::NEW_USER_COMMENT, name: 'New user comment', project_level: true)
NotificationType.create!(id: NotificationType::PROJECT_CREATED, name: 'Project created', project_level: false)
NotificationType.create!(id: NotificationType::PROJECT_UPDATED, name: 'Project details updated', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_APPLIED, name: 'certification applied', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_ACTIVATED, name: 'certification activated', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_SUBMITTED_FOR_SCREENING, name: 'certification submitted for screening', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_SCREENED, name: 'certification screened', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_SUBMITTED_FOR_VERIFICATION, name: 'certification submitted for verification', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_VERIFIED, name: 'certification verified', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_APPEALED, name: 'Some criteria of certification are appealed', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_APPEAL_APPROVED, name: 'certification criteria appeal approved', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_SUBMITTED_FOR_VERIFICATION_AFTER_APPEAL, name: 'certification submitted after appeal', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_VERIFIED_AFTER_APPEAL, name: 'certification verified after appeal', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_APPROVED_BY_MNGT, name: 'certification approved by GORD management', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_APPROVED_BY_TOP_MNGT, name: 'certification approved by GORD top management', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_ISSUED, name: 'certification issued', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_REJECTED, name: 'certification rejected', project_level: true)
NotificationType.create!(id: NotificationType::CRITERION_SUBMITTED, name: 'Criterion submitted', project_level: true)
NotificationType.create!(id: NotificationType::CRITERION_VERIFIED, name: 'Criterion verified', project_level: true)
NotificationType.create!(id: NotificationType::CRITERION_APPEALED, name: 'Criterion appealed', project_level: true)
NotificationType.create!(id: NotificationType::CRITERION_SUBMITTED_AFTER_APPEAL, name: 'Criterion submitted after appeal', project_level: true)
NotificationType.create!(id: NotificationType::CRITERION_VERIFIED_AFTER_APPEAL, name: 'Criterion verified after appeal', project_level: true)
NotificationType.create!(id: NotificationType::CRITERION_OTHER_STATE_CHANGES, name: 'Other criterion state changes', project_level: true)
NotificationType.create!(id: NotificationType::CRITERION_ASSIGNMENT_CHANGED, name: 'Criterion assignment changed', project_level: true)
NotificationType.create!(id: NotificationType::CRITERION_SCORE_CHANGED, name: 'Criterion score changed', project_level: true)
NotificationType.create!(id: NotificationType::CRITERION_TEXT_CHANGED, name: 'Criterion text changed', project_level: true)
NotificationType.create!(id: NotificationType::REQUIREMENT_PROVIDED, name: 'Requirement provided', project_level: true)
NotificationType.create!(id: NotificationType::REQUIREMENT_OTHER_STATE_CHANGES, name: 'Other requirement state changes', project_level: true)
NotificationType.create!(id: NotificationType::REQUIREMENT_ASSIGNMENT_CHANGED, name: 'Requirement assignment changed', project_level: true)
NotificationType.create!(id: NotificationType::NEW_DOCUMENT_WAITING_FOR_APPROVAL, name: 'New document uploaded for criterion', project_level: true)
NotificationType.create!(id: NotificationType::DOCUMENT_APPROVED, name: 'Document approved', project_level: true)
NotificationType.create!(id: NotificationType::DOCUMENT_REJECTED, name: 'Document rejected', project_level: true)
NotificationType.create!(id: NotificationType::DOCUMENT_SUPERSEDED, name: 'Document superseded', project_level: true)
NotificationType.create!(id: NotificationType::NEW_TASK, name: 'New task', project_level: false)
NotificationType.create!(id: NotificationType::PROJECT_AUTHORIZATION_CHANGED, name: 'Project authorizations changed', project_level: true)

SchemeCategory.find_each do |category|
  case category.code
    when 'UC'
      category.display_weight = 10
    when 'S'
      category.display_weight = 20
    when 'E'
      category.display_weight = 30
    when 'W'
      category.display_weight = 40
    when 'M'
      category.display_weight = 50
    when 'IE'
      category.display_weight = 60
    when 'CE'
      category.display_weight = 70
    when 'MO'
      category.display_weight = 80
  end
  category.save
end
