# New bulding type group for ecoleaf
BuildingTypeGroup.find_or_create_by!(name: 'EcoLeaf', visible: true)
BuildingType.find_or_create_by!(
  name: 'Expo Site', 
  building_type_group: BuildingTypeGroup.find_by(name: 'EcoLeaf')
)

# Create certificates for certification type gsas EcoLeaf
Certificate.find_or_create_by!(
    name: 'Stage 1: Provisional Certificate', 
    certification_type: Certificate.certification_types[:ecoleaf_provisional_certificate], 
    certificate_type: Certificate.certificate_types[:ecoleaf], 
    assessment_stage: Certificate.assessment_stages[:ecoleaf_stage], 
    gsas_version: "2019", 
    display_weight: 45
)

Certificate.find_or_create_by!(
    name: 'Stage 2: Ecoleaf Certificate', 
    certification_type: Certificate.certification_types[:ecoleaf_certificate], 
    certificate_type: Certificate.certificate_types[:ecoleaf], 
    assessment_stage: Certificate.assessment_stages[:ecoleaf_stage], 
    gsas_version: "2019", 
    display_weight: 50
)

# Create Development Types 
DevelopmentType.find_or_create_by!(
  display_weight: 10, 
  certificate: 
    Certificate.find_by(
      certification_type: Certificate.certification_types[:ecoleaf_provisional_certificate],
      certificate_type: Certificate.certificate_types[:ecoleaf], 
      assessment_stage: Certificate.assessment_stages[:ecoleaf_stage], 
      gsas_version: "2019"
    ), 
  mixable: false, 
  name: 'Expo Site'
)

DevelopmentType.find_or_create_by!(
  display_weight: 10, 
  certificate: 
    Certificate.find_by(
      certification_type: Certificate.certification_types[:ecoleaf_certificate],
      certificate_type: Certificate.certificate_types[:ecoleaf], 
      assessment_stage: Certificate.assessment_stages[:ecoleaf_stage], 
      gsas_version: "2019"
    ), 
  mixable: false, 
  name: 'Expo Site'
)
