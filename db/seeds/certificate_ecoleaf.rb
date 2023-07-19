# New bulding type group for ecoleaf
BuildingTypeGroup.find_or_create_by!(name: 'EcoLeaf', visible: true)
BuildingType.find_or_create_by!(
  name: 'Expo Site', 
  building_type_group: BuildingTypeGroup.find_by(name: 'EcoLeaf')
)

# Create certificates for certification type gsas EcoLeaf
el_provisional_certificate = 
  Certificate.find_or_create_by!(
      name: 'GSAS-EcoLeaf, Stage 1: Provisional Certificate', 
      certification_type: Certificate.certification_types[:ecoleaf_provisional_certificate], 
      certificate_type: Certificate.certificate_types[:ecoleaf], 
      assessment_stage: Certificate.assessment_stages[:ecoleaf_stage], 
      gsas_version: "2019", 
      display_weight: 45
  )

el_final_certificate = 
  Certificate.find_or_create_by!(
    name: 'GSAS-EcoLeaf, Stage 2: Ecoleaf Certificate', 
    certification_type: Certificate.certification_types[:ecoleaf_certificate], 
    certificate_type: Certificate.certificate_types[:ecoleaf], 
    assessment_stage: Certificate.assessment_stages[:ecoleaf_stage], 
    gsas_version: "2019", 
    display_weight: 50
  )

# Create Development Types 
el_provisional_developement_type = 
  DevelopmentType.find_or_create_by!(
    name: 'Expo Site',
    display_weight: 10, 
    certificate: el_provisional_certificate,
    mixable: false
  )

el_final_developement_type = 
  DevelopmentType.find_or_create_by!(
    name: 'Expo Site',
    display_weight: 10, 
    certificate: el_final_certificate,
    mixable: false
  )

# Create Schemes
el_provisional_exposite_scheme = 
  Scheme.find_or_create_by!(
    name: "Expo Site", 
    gsas_document: "GSAS Building Typologies_Assessment_2019_14.html", 
    gsas_version: "2019", 
    certification_type: Certificate.certification_types[:ecoleaf_provisional_certificate],
    certificate_type: Certificate.certificate_types[:ecoleaf], 
    renovation: false
  )

el_final_exposite_scheme = 
  Scheme.find_or_create_by!(
    name: "Expo Site", 
    gsas_document: "GSAS Building Typologies_Assessment_2019_14.html", 
    gsas_version: "2019", 
    certification_type: Certificate.certification_types[:ecoleaf_certificate],
    certificate_type: Certificate.certificate_types[:ecoleaf],  
    renovation: false
  )

# Create Development type schemes
el_provisional_developement_type_scheme = 
  DevelopmentTypeScheme.find_or_create_by!(
    scheme: el_provisional_exposite_scheme, 
    development_type: el_provisional_developement_type
  )

el_final_developement_type_scheme = 
  DevelopmentTypeScheme.find_or_create_by!(
    scheme: el_final_exposite_scheme, 
    development_type: el_final_developement_type
  )

# Create Scheme Categories
el_provisional_scheme_category = 
  SchemeCategory.find_or_create_by!(
    scheme: el_provisional_exposite_scheme, 
    code: "EL", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )

el_final_scheme_category = 
  SchemeCategory.find_or_create_by!(
    scheme: el_final_exposite_scheme, 
    code: "EL", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )

# Create Scheme Criteria & scheme criteria boxes
# --------------------------------- EL.1 ----------------------------------
el_1_provisional_scheme_criteria = 
  SchemeCriterion.find_or_create_by!(
    name: "Energy Management", 
    number: 1, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by!(
  scheme_criterion: el_1_provisional_scheme_criteria, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by!(
  scheme_criterion: el_1_provisional_scheme_criteria, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by!(
  scheme_criterion: el_1_provisional_scheme_criteria, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_1_final_scheme_criteria = 
  SchemeCriterion.find_or_create_by!(
    name: "Energy Management", 
    number: 1, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by!(
  scheme_criterion: el_1_final_scheme_criteria, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by!(
  scheme_criterion: el_1_final_scheme_criteria, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by!(
  scheme_criterion: el_1_final_scheme_criteria, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_1_criteria_information = 
  [
    "Apply passive design measures to reduce the energy demand. Increase surface reflectance through the use of reflective paints, materials, or coatings.",
    "Use hybrid ventilation strategies, such as providing operable windows, where possible.",
    "Provide efficient LED lighting options in accordance with CIBSE/IESNA standards for the required illuminance and uniformity levels. The lighting for interior and exterior spaces should provide adequate visual comfort while avoiding over-lighting to reduce energy consumption.",
    "Provide energy-efficient electrical appliances to reduce the electricity requirements of plug loads and reduce heat gains in air-conditioned areas from the usage of appliances, office equipment, and other devices plugged into electrical outlets.",
    "Avoid the use of temperature sensors that can be adjusted and tempered locally.",
    "Ensure cooling equipment's compliance with ASHRAE 90.1 - 2019 or equivalent for minimum equipment efficiency. Efficiency should be verified through certification under an approved certification program. If no certification program exists, the equipment's efficiency ratings should be supported by data furnished by the manufacturer.",
    "Install direct digital control systems to optimize the start-up or shut-down of the HVAC systems.",
    "Install an energy recovery system to recover the heating or cooling from the exhaust air before discharging it outdoors.",
    "Provide ventilation systems that can designate the appropriate amount of outside air ventilation to provide a comfortable environment for users. Avoid excessive amounts of outside air which will result in a high level of energy consumption.",
    "Select an efficient hot water generation system for the appropriate application, either central or individual type.",
    "Install appropriate metering equipment and monitoring devices for the measurement of energy performance and recording of energy consumption.",
    "Install lighting management control systems, including occupancy sensors, timers, and photo sensors, to switch lighting off when not required.",
    "Use generators that are not oversized and run at low load conditions. Calculate the generator load factor based on the KWh that the generator would have produced at rated power and the actual KWh reading from the generator energy meter.",
    "Monitor the overall electricity consumption from generators.",
    "Connect to the grid wherever possible, if renewables are not available."
  ]

el_1_criteria_information.each.with_index(1) do |ci, i|
  SchemeCriterionText.find_or_create_by!(
    scheme_criterion: el_1_provisional_scheme_criteria,
    display_weight: 1, 
    visible: true,
    name: "1.#{i}",
    html_text: 
      "
        <p>
          #{ci}
        </p>\n
        <p>&nbsp;</p>
      "
  )
end

