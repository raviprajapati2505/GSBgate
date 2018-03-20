# ruby encoding: utf-8
# Incentive Weights
# ["Healthcare", "Sports", "Railways", "Parks"].each do |scheme_name|
#   [{:code => "S", :name => "GSAS Construction Management - Full", :incentive => 1.0},
#    {:code => "M", :name => "Life Cycle Assessment (LCA)", :incentive => 2.0},
#    {:code => "MO", :name => "Energy & Water Use Sub-metering", :incentive => 1.0}
#   ].each do |incentive_criteria|
#     schemes = Scheme.where(name: scheme_name, gsas_version: "2.1", certificate_type: Certificate.certificate_types[:design_type])
#     schemes.each do | scheme|
#       criterion = SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: incentive_criteria[:code], scheme: scheme), name: incentive_criteria[:name])
#       #criterion.update_attributes(:incentive_weight_minus_1 => 0, :incentive_weight_0 => 0, :incentive_weight_1 => incentive_criteria[:incentive], :incentive_weight_2 => incentive_criteria[:incentive], :incentive_weight_3 => incentive_criteria[:incentive], :weight => criterion.weight - incentive_criteria[:incentive]) unless criterion.nil?
#       criterion.update_attributes(:incentive_weight_minus_1 => 0, :incentive_weight_0 => 0, :incentive_weight_1 => incentive_criteria[:incentive], :incentive_weight_2 => incentive_criteria[:incentive], :incentive_weight_3 => incentive_criteria[:incentive]) unless criterion.nil?
#     end
#   end
# end

SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Commercial', 'Core + Shell', 'Education', 'Hotels', 'Light Industry', 'Mosques', 'Parks', 'Residential - Group'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_minus_1: 0)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Commercial', 'Core + Shell', 'Education', 'Hotels', 'Light Industry', 'Mosques', 'Parks', 'Residential - Group'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_0: 0)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Commercial', 'Core + Shell', 'Education', 'Hotels', 'Light Industry', 'Mosques', 'Parks', 'Residential - Group'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_1: 0.5)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Commercial', 'Core + Shell', 'Education', 'Hotels', 'Light Industry', 'Mosques', 'Parks', 'Residential - Group'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_2: 1)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Commercial', 'Core + Shell', 'Education', 'Hotels', 'Light Industry', 'Mosques', 'Parks', 'Residential - Group'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_3: 2)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Commercial', 'Core + Shell', 'Education', 'Hotels', 'Light Industry', 'Mosques', 'Parks', 'Residential - Group'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all('weight = weight - 2.0')

SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Healthcare', 'Railways', 'Sports'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_minus_1: 0)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Healthcare', 'Railways', 'Sports'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_0: 0)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Healthcare', 'Railways', 'Sports'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_1: 0.25)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Healthcare', 'Railways', 'Sports'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_2: 0.5)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Healthcare', 'Railways', 'Sports'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_3: 1)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Healthcare', 'Railways', 'Sports'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all('weight = weight - 1.0')

SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'MO'}, number: 5, name: 'Energy & Water Use Sub-metering').update_all(incentive_weight_minus_1: 0)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'MO'}, number: 5, name: 'Energy & Water Use Sub-metering').update_all(incentive_weight_0: 0)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'MO'}, number: 5, name: 'Energy & Water Use Sub-metering').update_all(incentive_weight_1: 0.5)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'MO'}, number: 5, name: 'Energy & Water Use Sub-metering').update_all(incentive_weight_2: 0.5)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'MO'}, number: 5, name: 'Energy & Water Use Sub-metering').update_all(incentive_weight_3: 1)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'MO'}, number: 5, name: 'Energy & Water Use Sub-metering').update_all('weight = weight - 1.0')

SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'M'}, name: 'Life Cycle Assessment (LCA)').update_all(incentive_weight_minus_1: 0)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'M'}, name: 'Life Cycle Assessment (LCA)').update_all(incentive_weight_0: 0)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'M'}, name: 'Life Cycle Assessment (LCA)').update_all(incentive_weight_1: 2)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'M'}, name: 'Life Cycle Assessment (LCA)').update_all(incentive_weight_2: 2)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'M'}, name: 'Life Cycle Assessment (LCA)').update_all(incentive_weight_3: 2)
SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'M'}, name: 'Life Cycle Assessment (LCA)').update_all('weight = weight - 2.0')


# ec1 = Calculator.create!(name: 'Calculator::Dummy')
# wc1 = Calculator.create!(name: 'Calculator::Dummy')
# req1 = Requirement.create!(calculator: ec1, name: 'Energy calculator')
# req2 = Requirement.create!(calculator: wc1, name: 'Water calculator')
# req3 = Requirement.create!(name: 'Specifications and documentation regarding the available infrastructure showing that the existing structures can handle the additional load from the building')
# req4 = Requirement.create!(name: 'Ground plan')
# req5 = Requirement.create!(name: 'Ventilation plan')

CertificationPathStatus.create!(id: CertificationPathStatus::ACTIVATING, name: 'Activating', past_name: 'Activated', description: 'The certification is registered. After payment is received, a GSAS trust administrator will advance the status of the certification.')
CertificationPathStatus.create!(id: CertificationPathStatus::SUBMITTING, name: 'Submitting', past_name: 'Submitted', description: 'The certification is activated by a GSAS trust administrator. The project team can now provide the requirements for all criteria and set the submitted scores of all criteria. When all criteria are completed, a CGP project manager will advance the status of the certification.')
CertificationPathStatus.create!(id: CertificationPathStatus::SCREENING, name: 'Screening', past_name: 'Screened', description: 'The project team has completed all criteria. After the GSAS trust team has screened the criteria input, a GSAS trust certification manager will advance the status of the certification and provide screening comments.')
CertificationPathStatus.create!(id: CertificationPathStatus::SUBMITTING_AFTER_SCREENING, name: 'Submitting after screening', past_name: 'Submitted after screening', description: 'The GSAS trust team has screened and commented the criteria input. The project team can process this feedback by editing the existing criteria input. When all criteria are completed, a CGP project manager will advance the status of the certification.')
CertificationPathStatus.create!(id: CertificationPathStatus::VERIFYING, name: 'Verifying', past_name: 'Verified', description: 'The project team has completed all criteria. The GSAS trust team will now review all criteria input and set the the achieved scores of the criteria. After all criteria are verified, a GSAS trust certification manager will advance the status of the certification.')
CertificationPathStatus.create!(id: CertificationPathStatus::ACKNOWLEDGING, name: 'Acknowledging', past_name: 'Acknowledged', description: 'The GSAS trust team has verified all criteria. A CGP project manager will now decide to accept all scores or apply for appeal. After this, the certification status will be advanced.')
CertificationPathStatus.create!(id: CertificationPathStatus::PROCESSING_APPEAL_PAYMENT, name: 'Processing appeal payment', past_name: 'Appeal payment processed', description: 'An appeal was requested by a CGP project manager. After payment is received, a GSAS trust administrator will advance the status of the certification.')
CertificationPathStatus.create!(id: CertificationPathStatus::SUBMITTING_AFTER_APPEAL, name: 'Submitting after appeal', past_name: 'Submitted after appeal', description: 'An appeal was requested by a CGP project manager. The project team can now (re)provide the requirements for all criteria and set the submitted scores of all criteria. When all criteria are completed, a CGP project manager can advance the status of the certification.')
CertificationPathStatus.create!(id: CertificationPathStatus::VERIFYING_AFTER_APPEAL, name: 'Verifying after appeal', past_name: 'Verified after appeal', description: 'The project team has completed all criteria. The GSAS trust team will now review all criteria input and set the the achieved scores of the criteria. After all criteria are reviewed, a GSAS trust certification manager will advance the status of the certification.')
CertificationPathStatus.create!(id: CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL, name: 'Acknowledging after appeal', past_name: 'Acknowledged after appeal', description: 'The GSAS trust team has verified all criteria. After a CGP project manager acknowledges the achieved scores, he will advance the status of the certification.')
CertificationPathStatus.create!(id: CertificationPathStatus::APPROVING_BY_MANAGEMENT, name: 'Approving by Head of GSAS', past_name: 'Approved by Head of GSAS', description: 'The GSAS trust team approved this certification. The Head of GSAS will now approve the certification and advance the status.')
CertificationPathStatus.create!(id: CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT, name: 'Approving by Chairman', past_name: 'Approved by Chairman', description: 'The Head of GSAS approved this certification. The Chairman will now approve the certification and advance the status.')
CertificationPathStatus.create!(id: CertificationPathStatus::CERTIFIED, name: 'Certified', past_name: 'Certified', description: 'The GSAS trust team has issued this certification.')
CertificationPathStatus.create!(id: CertificationPathStatus::NOT_CERTIFIED, name: 'Not certified', past_name: 'Not certified', description: 'The GSAS trust team has denied this certification.')

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
NotificationType.create!(id: NotificationType::CERTIFICATE_APPROVED_BY_MNGT, name: 'certification approved by Head of GSAS', project_level: true)
NotificationType.create!(id: NotificationType::CERTIFICATE_APPROVED_BY_TOP_MNGT, name: 'certification approved by Chairman', project_level: true)
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

Owner.create!(name: 'Ministry of Environment', governmental: true)
Owner.create!(name: 'Ministry of Municipality and Urban Planning', governmental: true)
Owner.create!(name: 'Public Works Authority (ASHGHAL)', governmental: true)
Owner.create!(name: 'Supreme Committee for Delivery and Legacy', governmental: true)
Owner.create!(name: 'Qatar University', governmental: true)
Owner.create!(name: 'Hamad Medical Corporation', governmental: true)
Owner.create!(name: 'Aspire Zone Foundation', governmental: true)
Owner.create!(name: 'Qatar Rail', governmental: true)
Owner.create!(name: 'Economic Zone Company (MANATEQ)', governmental: true)
Owner.create!(name: 'Internal Security Force (Lekhwiya)', governmental: true)
Owner.create!(name: 'KATARA', governmental: true)
Owner.create!(name: 'Qatar Foundation', governmental: true)
Owner.create!(name: 'Qatar Science and Technology Park', governmental: true)
Owner.create!(name: 'Qatar Olympic Committee', governmental: true)
Owner.create!(name: 'Qatar General Electricity and Water Corporation (KAHRAMAA)', governmental: true)
Owner.create!(name: 'Private Engineering Office', governmental: true)
Owner.create!(name: 'Supreme Education Council', governmental: true)
Owner.create!(name: 'Supreme Council of Health', governmental: true)
Owner.create!(name: 'Qatar Museums Authority', governmental: true)
Owner.create!(name: 'New Port Project', governmental: true)
Owner.create!(name: 'Lusail Real Estate Development', private_developer: true)
Owner.create!(name: 'Hermas Development', private_developer: true)
Owner.create!(name: 'Al Asmakh Real Estate Development Co.', private_developer: true)
Owner.create!(name: 'Mumtalakat Real Estate ', private_developer: true)
Owner.create!(name: 'Qatari Diar', private_developer: true)
Owner.create!(name: 'Al Bandary Real Estate', private_developer: true)
Owner.create!(name: 'Al Emadi Enterprises', private_developer: true)
Owner.create!(name: 'Bawabat Al Shamal Real Estate Co.', private_developer: true)
Owner.create!(name: 'Msheireb Properties', private_developer: true)
Owner.create!(name: 'Sama Development Company', private_developer: true)
Owner.create!(name: 'Tameer Real Estate Co.', private_developer: true)
Owner.create!(name: 'Al Wahran Management Co.', private_developer: true)
Owner.create!(name: 'Al Shareef Enterprises', private_developer: true)
Owner.create!(name: 'Al Hikmah International Enterprises', private_developer: true)
Owner.create!(name: 'QIG Properties', private_developer: true)
Owner.create!(name: 'Mashour Real Estate Development', private_developer: true)
Owner.create!(name: 'Ali Bin Khalifa Al Hitmi & Co.', private_developer: true)
Owner.create!(name: 'Ali Abdulla Al Darwish', private_developer: true)
Owner.create!(name: 'Nasser Rashid Suraiya Al Kaabi', private_owner: true)
Owner.create!(name: 'Atiq Abdulla Al Kaabi', private_owner: true)
Owner.create!(name: 'Dr. Wael Hisham El Hariry', private_owner: true)
Owner.create!(name: 'Mohamed Hassam Al Asmakh', private_owner: true)
Owner.create!(name: 'Mohammad Bin Khalid Al Manaa', private_owner: true)
Owner.create!(name: 'Mohamed Ibrahim Al Asmakh', private_owner: true)
Owner.create!(name: 'Nasser Rahman Al Emadi', private_owner: true)
Owner.create!(name: 'Omar Abdulazziz Al Hamid Al Marwani', private_owner: true)
Owner.create!(name: 'Saeed Abdulla Al Kaabi', private_owner: true)
Owner.create!(name: 'Shk. Mansour Jabor Jassim Al Thani', private_owner: true)
Owner.create!(name: 'Shk. Jassim Faisal Al Thani', private_owner: true)
Owner.create!(name: 'Shk. Khaled Hamad Al Thani', private_owner: true)
Owner.create!(name: 'Shk. Khalid Jassim Al Thani', private_owner: true)
Owner.create!(name: 'Shk. Ahmed bin Abdulla bin Zail Al Mahmoud', private_owner: true)
Owner.create!(name: 'Mohamed Naser Hassan Al Nasr', private_owner: true)
Owner.create!(name: 'Abdulla Bin Fahad Al Marri', private_owner: true)

AuditLogVisibility.create!(name: 'public')
AuditLogVisibility.create!(name: 'GSAS trust team internal')

# Main building types (level 0)
BuildingTypeGroup.create!(id: 1, name: 'Railways')
BuildingTypeGroup.create!(id: 2, name: 'Sports')
BuildingTypeGroup.create!(id: 3, name: 'Hotel')
BuildingTypeGroup.create!(id: 4, name: 'Commercial')
BuildingTypeGroup.create!(id: 5, name: 'Light Industry')
BuildingTypeGroup.create!(id: 6, name: 'Education')
BuildingTypeGroup.create!(id: 7, name: 'CORE + SHELL')
BuildingTypeGroup.create!(id: 8, name: 'District & Infrastructure')
BuildingTypeGroup.create!(id: 9, name: 'Healthcare')
BuildingTypeGroup.create!(id: 10, name: 'Mosques')
BuildingTypeGroup.create!(id: 11, name: 'Parks')
BuildingTypeGroup.create!(id: 12, name: 'Group Residential')
BuildingTypeGroup.create!(id: 13, name: 'Single Residential')
BuildingTypeGroup.create!(id: 14, name: 'Workers Accommodation')

# Sub building types (level 1)
BuildingType.create!(id: 9, name: 'Railway Station', parent_id: 1)
BuildingType.create!(id: 10, name: 'Railway Network', parent_id: 1)
BuildingType.create!(id: 11, name: 'Passenger Terminal', parent_id: 1)

BuildingType.create!(id: 12, name: 'Sport Arena', parent_id: 2)
BuildingType.create!(id: 13, name: 'Sport Center', parent_id: 2)
BuildingType.create!(id: 14, name: 'Stadium', parent_id: 2)
BuildingType.create!(id: 15, name: 'Other', parent_id: 2)
BuildingType.create!(id: 16, name: 'Community Center', parent_id: 2)

BuildingType.create!(id: 17, name: 'Service Apartments', parent_id: 3)
BuildingType.create!(id: 18, name: 'Hotel', parent_id: 3)

BuildingType.create!(id: 19, name: 'Utility Building', parent_id: 4)
BuildingType.create!(id: 20, name: 'Theater', parent_id: 4)
BuildingType.create!(id: 21, name: 'Court', parent_id: 4)
BuildingType.create!(id: 22, name: 'Office', parent_id: 4)
BuildingType.create!(id: 23, name: 'Retail', parent_id: 4)
BuildingType.create!(id: 24, name: 'Restaurant', parent_id: 4)
BuildingType.create!(id: 25, name: 'Library', parent_id: 4)
BuildingType.create!(id: 26, name: 'Museum or Gallery', parent_id: 4)

BuildingType.create!(id: 27, name: 'Warehouse', parent_id: 5)
BuildingType.create!(id: 28, name: 'Workshop', parent_id: 5)
BuildingType.create!(id: 29, name: 'Industrial Process Building', parent_id: 5)
BuildingType.create!(id: 30, name: 'Other', parent_id: 5)

BuildingType.create!(id: 31, name: 'University / College', parent_id: 6)
BuildingType.create!(id: 32, name: 'Primary School', parent_id: 6)
BuildingType.create!(id: 33, name: 'Secondary School', parent_id: 6)
BuildingType.create!(id: 34, name: 'Other', parent_id: 6)

BuildingType.create!(id: 35, name: 'Shopping Mall', parent_id: 7)
BuildingType.create!(id: 36, name: 'Other', parent_id: 7)

BuildingType.create!(id: 37, name: 'Neighborhood', parent_id: 8)
BuildingType.create!(id: 38, name: 'Sport', parent_id: 8)
BuildingType.create!(id: 39, name: 'Healthcare', parent_id: 8)
BuildingType.create!(id: 40, name: 'Industrial', parent_id: 8)
BuildingType.create!(id: 41, name: 'Entertainment', parent_id: 8)
BuildingType.create!(id: 42, name: 'Education', parent_id: 8)
BuildingType.create!(id: 43, name: 'Transportation', parent_id: 8)

BuildingType.create!(id: 36, name: 'Clinics', building_type_group_id: 9)
BuildingType.create!(id: 37, name: 'Hospital', building_type_group_id: 9)
BuildingType.create!(id: 38, name: 'Laboratories', building_type_group_id: 9)
BuildingType.create!(id: 39, name: 'Medical Research Centre', building_type_group_id: 9)

BuildingType.create!(id: 40, name: 'Neighborhood Mosque', building_type_group_id: 10)
BuildingType.create!(id: 41, name: 'Friday Mosque', building_type_group_id: 10)
BuildingType.create!(id: 42, name: 'Eid Prayer Mosque', building_type_group_id: 10)

BuildingType.create!(id: 43, name: 'Neighborhood Park', building_type_group_id: 11)
BuildingType.create!(id: 44, name: 'District Park', building_type_group_id: 11)
BuildingType.create!(id: 45, name: 'Water Park', building_type_group_id: 11)
BuildingType.create!(id: 46, name: 'Open Land', building_type_group_id: 11)

BuildingType.create!(id: 47, name: 'Apartments/ Flats Building', building_type_group_id: 12)

BuildingType.create!(id: 48, name: 'Detached House/ Villa', building_type_group_id: 13)
BuildingType.create!(id: 49, name: 'Semi Detached House', building_type_group_id: 13)
BuildingType.create!(id: 50, name: 'Townhouse', building_type_group_id: 13)

BuildingType.create!(id: 51, name: 'Single Bedroom Unit/ Studio', building_type_group_id: 14)
BuildingType.create!(id: 52, name: 'Shared Bedroom Unit/ Dormitory Rooms', building_type_group_id: 14)