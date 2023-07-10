# introduce new bulding type group for ecoleafe
BuildingTypeGroup.create!(id: 22, name: 'EcoLeafe')
BuildingType.create!(id: 105, name: 'Expo Site', building_type_group_id: 22)

# new certificate for certification type gsas ecoleafe
Certificate.create!(
    name: 'GSAS-EcoLeaf, 2019', 
    certification_type: Certificate.certification_types[:ecoleafe_certificate], 
    certificate_type: Certificate.certificate_types[:ecoleaf], 
    assessment_stage: Certificate.assessment_stages[:ecoleaf_stage], 
    gsas_version: "2019", 
    display_weight: 50
)

Certificate.create!(
    name: 'GSAS-EcoLeaf, 2019', 
    certification_type: Certificate.certification_types[:provisional_certificate], 
    certificate_type: Certificate.certificate_types[:ecoleaf], 
    assessment_stage: Certificate.assessment_stages[:ecoleaf_stage], 
    gsas_version: "2019", 
    display_weight: 45
)