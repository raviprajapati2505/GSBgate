# New bulding type group for ecoleaf
BuildingTypeGroup.find_or_create_by!(name: 'EcoLeaf', visible: true)
BuildingType.find_or_create_by!(
  name: 'Expo Site', 
  building_type_group: BuildingTypeGroup.find_by(name: 'EcoLeaf')
)

# Create certificates for certification type gsas EcoLeaf
Certificate.find_or_create_by!(
    name: 'GSAS-EcoLeaf, Stage 1: Provisional Certificate', 
    certification_type: Certificate.certification_types[:ecoleaf_provisional_certificate], 
    certificate_type: Certificate.certificate_types[:ecoleaf], 
    assessment_stage: Certificate.assessment_stages[:ecoleaf_stage], 
    gsas_version: "2019", 
    display_weight: 45
)

Certificate.find_or_create_by!(
    name: 'GSAS-EcoLeaf, Stage 2: Ecoleaf Certificate', 
    certification_type: Certificate.certification_types[:ecoleaf_certificate], 
    certificate_type: Certificate.certificate_types[:ecoleaf], 
    assessment_stage: Certificate.assessment_stages[:ecoleaf_stage], 
    gsas_version: "2019", 
    display_weight: 50
)

# Create Development Types 
DevelopmentType.find_or_create_by!(
  name: 'Expo Site',
  display_weight: 10, 
  certificate: 
    Certificate.find_by(
      certification_type: Certificate.certification_types[:ecoleaf_provisional_certificate],
      certificate_type: Certificate.certificate_types[:ecoleaf], 
      assessment_stage: Certificate.assessment_stages[:ecoleaf_stage], 
      gsas_version: "2019"
    ),
  mixable: false
)

DevelopmentType.find_or_create_by!(
  name: 'Expo Site',
  display_weight: 10, 
  certificate: 
    Certificate.find_by(
      certification_type: Certificate.certification_types[:ecoleaf_certificate],
      certificate_type: Certificate.certificate_types[:ecoleaf], 
      assessment_stage: Certificate.assessment_stages[:ecoleaf_stage], 
      gsas_version: "2019"
    ),
  mixable: false
)

# Create Schemes
Scheme.find_or_create_by!(
  name: "Expo Site", 
  gsas_document: "GSAS Building Typologies_Assessment_2019_14.html", 
  gsas_version: "2019", 
  certification_type: Certificate.certification_types[:ecoleaf_provisional_certificate],
  certificate_type: Certificate.certificate_types[:ecoleaf], 
  renovation: false
)

Scheme.find_or_create_by!(
  name: "Expo Site", 
  gsas_document: "GSAS Building Typologies_Assessment_2019_14.html", 
  gsas_version: "2019", 
  certification_type: Certificate.certification_types[:ecoleaf_certificate],
  certificate_type: Certificate.certificate_types[:ecoleaf],  
  renovation: false
)

# Create Development type schemes
DevelopmentTypeScheme.find_or_create_by!(
  scheme: 
    Scheme.find_by(
      name: "Expo Site", 
      gsas_document: "GSAS Building Typologies_Assessment_2019_14.html", 
      gsas_version: "2019", 
      certification_type: Certificate.certification_types[:ecoleaf_provisional_certificate],
      certificate_type: Certificate.certificate_types[:ecoleaf], 
      renovation: false
    ), 
  development_type: 
    DevelopmentType.find_by(
      name: 'Expo Site',
      certificate: 
        Certificate.find_by(
          certification_type: Certificate.certification_types[:ecoleaf_provisional_certificate],
          certificate_type: Certificate.certificate_types[:ecoleaf], 
          assessment_stage: Certificate.assessment_stages[:ecoleaf_stage], 
          gsas_version: "2019"
        ),
    )
)

DevelopmentTypeScheme.find_or_create_by!(
  scheme: 
    Scheme.find_by(
      name: "Expo Site", 
      gsas_document: "GSAS Building Typologies_Assessment_2019_14.html", 
      gsas_version: "2019", 
      certification_type: Certificate.certification_types[:ecoleaf_certificate],
      certificate_type: Certificate.certificate_types[:ecoleaf],  
      renovation: false
    ), 
  development_type: 
    DevelopmentType.find_by(
      name: 'Expo Site',
      certificate: 
        Certificate.find_by(
          certification_type: Certificate.certification_types[:ecoleaf_certificate],
          certificate_type: Certificate.certificate_types[:ecoleaf], 
          assessment_stage: Certificate.assessment_stages[:ecoleaf_stage], 
          gsas_version: "2019"
        ),
    )
)
