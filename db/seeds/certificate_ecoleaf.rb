# Create bulding type group for ecoleaf

# Reset primary key sequence
tables = ["building_type_groups", "building_types"]
tables.each do |t|
	ActiveRecord::Base.connection.reset_pk_sequence!("#{t}")
end

building_type_group = 
  BuildingTypeGroup.find_or_create_by(
    name: 'EcoLeaf', 
    visible: true
)
BuildingType.find_or_create_by(
  name: 'Expo Site', 
  building_type_group: building_type_group
)

# Create requirement category
requirement_category_for_design = 
  RequirementCategory.find_or_create_by(
    title: "Design",
    display_weight: 1
  )
requirement_category_for_construction = 
  RequirementCategory.find_or_create_by(
    title: "Construction",
    display_weight: 2
  )
requirement_category_for_operation = 
  RequirementCategory.find_or_create_by(
    title: "Operations",
    display_weight: 3
  )
requirement_category_for_dismantling = 
  RequirementCategory.find_or_create_by(
    title: "Dismantling",
    display_weight: 4
  )

# Create certificates for certification type gsas EcoLeaf
el_provisional_certificate = 
  Certificate.find_or_create_by(
      name: 'GSAS-EcoLeaf, Stage 1: Provisional Certificate', 
      certification_type: Certificate.certification_types[:ecoleaf_provisional_certificate], 
      certificate_type: Certificate.certificate_types[:ecoleaf_type], 
      assessment_stage: Certificate.assessment_stages[:ecoleaf_stage], 
      gsas_version: "2019", 
      display_weight: 45
  )

el_final_certificate = 
  Certificate.find_or_create_by(
    name: 'GSAS-EcoLeaf, Stage 2: Ecoleaf Certificate', 
    certification_type: Certificate.certification_types[:ecoleaf_certificate], 
    certificate_type: Certificate.certificate_types[:ecoleaf_type], 
    assessment_stage: Certificate.assessment_stages[:ecoleaf_stage], 
    gsas_version: "2019", 
    display_weight: 50
  )

# Create Development Types 
el_provisional_developement_type = 
  DevelopmentType.find_or_create_by(
    name: 'Expo Site',
    display_weight: 10, 
    certificate: el_provisional_certificate,
    mixable: false
  )

el_final_developement_type = 
  DevelopmentType.find_or_create_by(
    name: 'Expo Site',
    display_weight: 10, 
    certificate: el_final_certificate,
    mixable: false
  )

el_neighborhoods_provisional_developement_type = 
  DevelopmentType.find_or_create_by(
    name: 'Neighborhoods',
    display_weight: 20, 
    certificate: el_provisional_certificate,
    mixable: true
  )

el_neighborhoods_final_developement_type = 
  DevelopmentType.find_or_create_by(
    name: 'Neighborhoods',
    display_weight: 20, 
    certificate: el_final_certificate,
    mixable: true
  )

# Create Schemes
el_provisional_exposite_scheme = 
  Scheme.find_or_create_by(
    name: "Expo Site", 
    gsas_document: "GSAS Building Typologies_Assessment_2019_14.html", 
    gsas_version: "2019", 
    certification_type: Certificate.certification_types[:ecoleaf_provisional_certificate],
    certificate_type: Certificate.certificate_types[:ecoleaf_type], 
    renovation: false
  )

el_final_exposite_scheme = 
  Scheme.find_or_create_by(
    name: "Expo Site", 
    gsas_document: "GSAS Building Typologies_Assessment_2019_14.html", 
    gsas_version: "2019", 
    certification_type: Certificate.certification_types[:ecoleaf_certificate],
    certificate_type: Certificate.certificate_types[:ecoleaf_type],  
    renovation: false
  )

# Create Development type schemes
el_provisional_developement_type_scheme = 
  DevelopmentTypeScheme.find_or_create_by(
    scheme: el_provisional_exposite_scheme, 
    development_type: el_provisional_developement_type
  )

el_final_developement_type_scheme = 
  DevelopmentTypeScheme.find_or_create_by(
    scheme: el_final_exposite_scheme, 
    development_type: el_final_developement_type
  )

el_provisional_developement_type_neighbourhoods_scheme = 
  DevelopmentTypeScheme.find_or_create_by(
    scheme: el_provisional_exposite_scheme, 
    development_type: el_neighborhoods_provisional_developement_type
  )

el_provisional_developement_type_neighbourhoods_scheme = 
  DevelopmentTypeScheme.find_or_create_by(
    scheme: el_final_exposite_scheme, 
    development_type: el_neighborhoods_final_developement_type
  )

# Create Scheme Categories
el_provisional_scheme_category = 
  SchemeCategory.find_or_create_by(
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
  SchemeCategory.find_or_create_by(
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
el_1_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Energy Management", 
    number: 1, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_1_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_1_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_1_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_1_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Energy Management", 
    number: 1, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_1_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_1_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_1_final_scheme_criterion, 
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

[el_1_provisional_scheme_criterion, el_1_final_scheme_criterion].each do |criterion|
  el_1_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_1_design_requirements = 
  [
    "Architectural Drawings",
    "Tentative Material Selection",
    "Lighting Layouts",
    "Fit-out Layouts showing all equipment and appliances",
    "HVAC layouts showing the locations of thermostats (if any)",
    "HVAC layouts",
    "Tentative Equipment Selection",
    "Compliance calculations (reference to the table of the standard)",
    "Controls specifications",
    "Sequence of Operations",
    "Sensor proposed locations",
    "Plumbing layouts",
    "Single-line diagram highlighting the proposed meter locations",
    "Lighting layouts showing the locations of lighting controllers",
    "Generators specifications",
    "Correspondence with Utility Provider requesting connections"
  ]

el_1_design_requirements.each.with_index(1) do |ci, i|
  rt_for_el_1_scheme_criterion = nil

  rt_for_el_1_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_design
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_1_scheme_criterion, 
    scheme_criterion: el_1_provisional_scheme_criterion
  )

  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_1_scheme_criterion, 
    scheme_criterion: el_1_final_scheme_criterion
  )
end

el_1_construction_requirements = 
  [
    "Material Approval Requests",
    "Photos of the envelope",
    "Photos of the openings' mechanisms",
    "Photos of lighting fixtures",
    "Product Energy Labels",
    "Product Specifications, nameplates, or catalogs",
    "Photos of appliances",
    "Photos of thermostats (if any)",
    "Product nameplates",
    "Photos of equipment",
    "Updated compliance calculations (if applicable)",
    "Photos of Controls",
    "Sample of control schedule as shown from the DDC",
    "Photos of the sensors",
    "Controller Nameplates",
    "Screenshots of any of the controller parameters",
    "Functional Testing Checklist",
    "Photos of the installed meters (for temporary construction activities and Expo buildings)",
    "Logs of energy consumption of construction activities (weekly)",
    "Video for System Operations",
    "Meter readings",
    "Fuel logs",
    "Generator Efficiency calculations",
    "Logs of energy consumption of construction activities (weekly)",
    "Approval from the Utility Provider",
    "Photos for Utility meter"
  ]

el_1_construction_requirements.each.with_index(1) do |ci, i|
  rt_for_el_1_scheme_criterion = nil
  rt_for_el_1_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_construction
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_1_scheme_criterion, 
    scheme_criterion: el_1_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_1_scheme_criterion, 
    scheme_criterion: el_1_final_scheme_criterion
  )
end

el_1_operation_requirements = 
  [
    "Product Specifications, nameplates, or catalogs",
    "Photos of lighting fixtures",
    "Product Energy Labels",
    "Photos of appliances",
    "Photos of thermostats (if any)",
    "Logs of energy consumption (weekly)",
    "Video for System Operations",
    "Meter readings",
    "Fuel logs",
    "Generator Efficiency calculations",
    "Logs of energy consumption (weekly)",
    "Utility bills"
  ]

el_1_operation_requirements.each.with_index(1) do |ci, i|
  rt_for_el_1_scheme_criterion = nil
  rt_for_el_1_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_operation
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_1_scheme_criterion, 
    scheme_criterion: el_1_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_1_scheme_criterion, 
    scheme_criterion: el_1_final_scheme_criterion
  )
end

el_1_dismantling_requirements = 
  [
    "Photos of the installed meters (for temporary dismantling activities)",
    "Logs of energy consumption of dismantling activities (weekly)",
    "Meter readings",
    "Fuel logs",
    "Generator Efficiency calculations",
    "Photos of the installed meters (for temporary dismantling activities)",
    "Logs of energy consumption of dismantling activities (weekly)"
  ]

el_1_dismantling_requirements.each.with_index(1) do |ci, i|
  rt_for_el_1_scheme_criterion = nil
  rt_for_el_1_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_dismantling
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_1_scheme_criterion, 
    scheme_criterion: el_1_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_1_scheme_criterion, 
    scheme_criterion: el_1_final_scheme_criterion
  )
end

# --------------------------------- EL.2 ----------------------------------
el_2_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Renewable Energy", 
    number: 2, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_2_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_2_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_2_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_2_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Renewable Energy", 
    number: 2, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_2_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_2_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_2_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_2_criteria_information = 
  [
    "Use renewable energy where appropriate. Compliance is achieved when the percentage of the onsite renewable energy contribution to the total energy need of the development meets or exceeds the 10% limit."
  ]

[el_2_provisional_scheme_criterion, el_2_final_scheme_criterion].each do |criterion|
  el_2_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_2_design_requirements = 
  [
    "Layouts showing the location, orientation, and size of renewables onsite",
    "Tentative Renewables Selection",
    "Renewable systems power calculations",
    "Peak Demand calculations"
  ]

el_2_design_requirements.each.with_index(1) do |ci, i|
  rt_for_el_2_scheme_criterion = nil

  rt_for_el_2_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_design
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_2_scheme_criterion, 
    scheme_criterion: el_2_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_2_scheme_criterion, 
    scheme_criterion: el_2_final_scheme_criterion
  )
end

el_2_construction_requirements = 
  [
    "Photos of Renewables and Meters",
    "Updated Layouts (if any)",
    "Equipment Nameplates"
  ]

el_2_construction_requirements.each.with_index(1) do |ci, i|
  rt_for_el_2_scheme_criterion = nil
  rt_for_el_2_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_construction
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_2_scheme_criterion, 
    scheme_criterion: el_2_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_2_scheme_criterion, 
    scheme_criterion: el_2_final_scheme_criterion
  )
end

el_2_operation_requirements = 
  [
    "Logs for Renewable meters and Overall Electricity Meters for the whole event duration (Weekly)",
    "Calculations showing compliance"
  ]

el_2_operation_requirements.each.with_index(1) do |ci, i|
  rt_for_el_2_scheme_criterion = nil
  rt_for_el_2_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_operation
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_2_scheme_criterion, 
    scheme_criterion: el_2_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_2_scheme_criterion, 
    scheme_criterion: el_2_final_scheme_criterion
  )
end

# --------------------------------- EL.3 ----------------------------------
el_3_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Water Management", 
    number: 3, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_3_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_3_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_3_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_3_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Water Management", 
    number: 3, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_3_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_3_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_3_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_3_criteria_information = 
  [
    "Use water-efficient fixtures, for example, low flush toilets, vacuum toilet flush systems, dual flush toilets, flow- controllers, water-saving valves and fixtures on faucets and showerheads, and low flush urinals.",
    "Install water-efficient equipment and appliances including dishwashers, washing machines, or similar appliances, if applicable.",
    "Install an efficient irrigation system.",
    "Use a water-efficient landscape by specifying native plants that are more tolerant to local soil and rainfall conditions.",
    "Use TSE water for toilet flushing or landscape irrigation, where feasible.",
    "Collect, store, and reuse rainwater that falls on roofs, hardscapes, or any other above-ground catchment surfaces, and condensate water from HVAC equipment.",
    "Monitor water consumption and leak detection.",
    "Install, where possible, a mobile water treatment and purification system."
  ]

[el_3_provisional_scheme_criterion, el_3_final_scheme_criterion].each do |criterion|
  el_3_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_3_design_requirements = 
  [
    "Fit-out Layouts showing fixtures locations",
    "Tentative Fixture Selection",
    "Comparison sheet showing compliance",
    "Fit-out Layouts showing appliance locations",
    "Irrigation Layouts showing the irrigation network",
    "Landscape schedule",
    "Landscape Layouts",
    "Correspondence with Utility Provider requesting connections",
    "Plumbing Layouts showing the drainage of Rainwater and Condensate water",
    "Layouts showing water storage and reuse",
    "Water treatment (if any)",
    "Riser diagram highlighting the proposed meter locations",
    "Tentative Equipment Selection",
    "Layout showing the connections to the equipment"
  ]

el_3_design_requirements.each.with_index(1) do |ci, i|
  rt_for_el_3_scheme_criterion = nil

  rt_for_el_3_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_design
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_3_scheme_criterion, 
    scheme_criterion: el_3_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_3_scheme_criterion, 
    scheme_criterion: el_3_final_scheme_criterion
  )
end

el_3_construction_requirements = 
  [
    "Product Specifications or catalogs",
    "Comparison sheet showing compliance",
    "Photos of fixtures",
    "Product Specifications or catalogs",
    "Comparison sheet showing compliance, or Water Labels",
    "Photos of appliances",
    "Photos of the irrigation network",
    "Photos of planted species",
    "Approval from the Utility Provider",
    "Photos for Tie-in point and Utility meter",
    "Photos of the Rainwater collection network",
    "Photos of Water Storage",
    "Photos of the installed meters (for temporary construction activities and Expo buildings)",
    "Logs of water consumption of construction activities (weekly)",
    "Photos of the Equipment",
    "Equipment nameplates"
  ]

el_3_construction_requirements.each.with_index(1) do |ci, i|
  rt_for_el_3_scheme_criterion = nil
  rt_for_el_3_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_construction
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_3_scheme_criterion, 
    scheme_criterion: el_3_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_3_scheme_criterion, 
    scheme_criterion: el_3_final_scheme_criterion
  )
end

el_3_operation_requirements = 
  [
    "Product Specifications or catalogs",
    "Comparison sheet showing compliance, or Water Labels",
    "Photos of appliances",
    "Logs of water consumption (weekly)",
    "Photos of the Equipment",
    "Equipment nameplates"
  ]

el_3_operation_requirements.each.with_index(1) do |ci, i|
  rt_for_el_3_scheme_criterion = nil
  rt_for_el_3_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_operation
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_3_scheme_criterion, 
    scheme_criterion: el_3_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_3_scheme_criterion, 
    scheme_criterion: el_3_final_scheme_criterion
  )
end

el_3_dismantling_requirements = 
  [
    "Photos of the installed meters (for temporary dismantling activities)",
    "Logs of water consumption of dismantling activities (weekly)"
  ]

el_3_dismantling_requirements.each.with_index(1) do |ci, i|
  rt_for_el_3_scheme_criterion = nil
  rt_for_el_3_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_dismantling
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_3_scheme_criterion, 
    scheme_criterion: el_3_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_3_scheme_criterion, 
    scheme_criterion: el_3_final_scheme_criterion
  )
end

# --------------------------------- EL.4 ----------------------------------
el_4_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Land & Biodiversity Preservation", 
    number: 4, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_4_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_4_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_4_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_4_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Land & Biodiversity Preservation", 
    number: 4, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_4_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_4_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_4_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_4_criteria_information = 
  [
    "Ensure ecological conservation, site restoration, and soil contamination including the procedures and  guidelines for soil management during excavation, soil sampling, and backfilling works",
    "Enhance the existing ecological value of the event site.",
    "Restore the native ecology by replanting the disturbed vegetation and reintroducing the same species and habitats after the event is concluded.",
    "Protect and enhance the existing biodiversity including flora and fauna species."
  ]

[el_4_provisional_scheme_criterion, el_4_final_scheme_criterion].each do |criterion|
  el_4_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_4_design_requirements = 
  [
    "Environmental Soil Test",
    "Environmental Impact Assessment or Environmental Report showing land ecological value"
  ]

el_4_design_requirements.each.with_index(1) do |ci, i|
  rt_for_el_4_scheme_criterion = nil

  rt_for_el_4_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_design
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_4_scheme_criterion, 
    scheme_criterion: el_4_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_4_scheme_criterion, 
    scheme_criterion: el_4_final_scheme_criterion
  )
end

el_4_construction_requirements = 
  [
    "Environmental Soil Test",
    "Geotechnical Report",
    "CEMP",
    "Photos of Land enhancements",
    "Environmental Soil Test",
    "Landscape Layouts",
    "Terrestrial Survey",
    "Photos of protection measures implemented"
  ]

el_4_construction_requirements.each.with_index(1) do |ci, i|
  rt_for_el_4_scheme_criterion = nil
  rt_for_el_4_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_construction
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_4_scheme_criterion, 
    scheme_criterion: el_4_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_4_scheme_criterion, 
    scheme_criterion: el_4_final_scheme_criterion
  )
end

el_4_operation_requirements = 
  [
    "Photos of protection measures implemented"
  ]

el_4_operation_requirements.each.with_index(1) do |ci, i|
  rt_for_el_4_scheme_criterion = nil
  rt_for_el_4_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_operation
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_4_scheme_criterion, 
    scheme_criterion: el_4_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_4_scheme_criterion, 
    scheme_criterion: el_4_final_scheme_criterion
  )
end

el_4_dismantling_requirements = 
  [
    "Environmental Soil Test, upon Dismantling",
    "Photos of Land enhancements",
    "Environmental Soil Test, upon Dismantling",
    "Photos of Land enhancements",
    "List of removed plants",
    "List of plants used for restoration",
    "Terrestrial Survey",
    "Photos of protection measures implemented "
  ]

el_4_dismantling_requirements.each.with_index(1) do |ci, i|
  rt_for_el_4_scheme_criterion = nil
  rt_for_el_4_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_dismantling
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_4_scheme_criterion, 
    scheme_criterion: el_4_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_4_scheme_criterion, 
    scheme_criterion: el_4_final_scheme_criterion
  )
end

# --------------------------------- EL.5 ----------------------------------
el_5_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Waterbody Preservation", 
    number: 5, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_5_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_5_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_5_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_5_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Waterbody Preservation", 
    number: 5, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_5_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_5_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_5_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_5_criteria_information = 
  [
    "Implement conservation, restoration, and/or enhancement strategies and guidelines for natural waterbodies on or near the development site.",
    "Restore and enhance water quality and livable conditions of the adjacent or nearby waterbodies.",
    "Adhere to the coastal protection regulations which mandate the provision of a buffer between the boundaries of a development site and the waterbody."
  ]

[el_5_provisional_scheme_criterion, el_5_final_scheme_criterion].each do |criterion|
  el_5_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_5_design_requirements = 
  [
    "Environmental Impact Assessment",
    "Geotechnical Report",
    "Environmental Permit"
  ]

el_5_design_requirements.each.with_index(1) do |ci, i|
  rt_for_el_5_scheme_criterion = nil

  rt_for_el_5_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_design
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_5_scheme_criterion, 
    scheme_criterion: el_5_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_5_scheme_criterion, 
    scheme_criterion: el_5_final_scheme_criterion
  )
end

el_5_construction_requirements = 
  [
    "Photos of protection measures implemented",
    "CEMP",
    "Pre-construction Hydrological test",
    "Post-construction Hydrological test",
    "Photos of protection measures implemented"
  ]

el_5_construction_requirements.each.with_index(1) do |ci, i|
  rt_for_el_5_scheme_criterion = nil
  rt_for_el_5_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_construction
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_5_scheme_criterion, 
    scheme_criterion: el_5_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_5_scheme_criterion, 
    scheme_criterion: el_5_final_scheme_criterion
  )
end

el_5_dismantling_requirements = 
  [
    "Post-dismantling Hydrological test"
  ]

el_5_dismantling_requirements.each.with_index(1) do |ci, i|
  rt_for_el_5_scheme_criterion = nil
  rt_for_el_5_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_dismantling
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_5_scheme_criterion, 
    scheme_criterion: el_5_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_5_scheme_criterion, 
    scheme_criterion: el_5_final_scheme_criterion
  )
end

# --------------------------------- EL.6 ----------------------------------
el_6_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Accessibility", 
    number: 6, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_6_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_6_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_6_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_6_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Accessibility", 
    number: 6, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_6_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_6_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_6_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_6_criteria_information = 
  [
    "Apply specifications for accessible trails, picnic, and camping areas, viewing areas, beach access routes,  and other components of outdoor developed areas that meet the Architectural Barriers Act (ABA) for  Outdoor Spaces or other international standards.",
    "Implement signage strategies including but not limited to street signage, pathway labels, trash, and recycling receptacles, and directional signs leading to major attractions, parking, entrances, and exits.",
    "Install safety and advisory warning signs in hazardous and potentially hazardous areas, signs indicating all public, administrative, and maintenance facilities, and interpretative signs for any historical,  artistic, and cultural attractions.",
    "Ensure safe connection between the facilities and public areas including parking spaces, leisure areas and recreational spaces, etc.",
    "Ensure connectivity to the existing or planned transportation hubs, such as bus stops, rail or metro stations, and shuttle bus parking areas.",
    "Facilitate pedestrian pathways on the event site while encouraging visitors to walk for a healthy and sustainable lifestyle."
  ]

[el_6_provisional_scheme_criterion, el_6_final_scheme_criterion].each do |criterion|
  el_6_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_6_design_requirements = 
  [
    "Site layouts showing pedestrian pathways sized for two-way circulation",
    "Ramp details (showing inclination), if any",
    "Signage Layouts showing the locations of signs",
    "Signage schedule showing the content of the signs",
    "Signage Layouts showing the locations of signs",
    "Signage schedule showing the content of the signs",
    "Site layouts showing pedestrian pathways sized for two-way circulation",
    "Ramp details (showing inclination), if any",
    "Site layouts showing pedestrian pathways sized for two-way circulation",
    "Ramp details (showing inclination), if any",
    "Walkability awareness program"
  ]

el_6_design_requirements.each.with_index(1) do |ci, i|
  rt_for_el_6_scheme_criterion = nil

  rt_for_el_6_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_design
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_6_scheme_criterion, 
    scheme_criterion: el_6_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_6_scheme_criterion, 
    scheme_criterion: el_6_final_scheme_criterion
  )
end

el_6_construction_requirements = 
  [
    "Photos of Pathways",
    "Updated Layouts (if applicable)",
    "Photos of signs",
    "Updated Layouts (if applicable)",
    "Photos of Signage, brochures, or posters",
    "Proposed digital content for Walkability"
  ]

el_6_construction_requirements.each.with_index(1) do |ci, i|
  rt_for_el_6_scheme_criterion = nil
  rt_for_el_6_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_construction
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_6_scheme_criterion, 
    scheme_criterion: el_6_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_6_scheme_criterion, 
    scheme_criterion: el_6_final_scheme_criterion
  )
end

el_6_operation_requirements = 
  [
    "Photos of additional signs",
    "Updated Layouts (if applicable)"
  ]

el_6_operation_requirements.each.with_index(1) do |ci, i|
  rt_for_el_6_scheme_criterion = nil
  rt_for_el_6_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_operation
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_6_scheme_criterion, 
    scheme_criterion: el_6_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_6_scheme_criterion, 
    scheme_criterion: el_6_final_scheme_criterion
  )
end

# --------------------------------- EL.7 ----------------------------------
el_7_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Sustainable Architecture", 
    number: 7, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_7_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_7_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_7_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_7_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Sustainable Architecture", 
    number: 7, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_7_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_7_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_7_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_7_criteria_information = 
  [
    "Provide shading on outdoor areas including queuing  corridors, pathways, public areas, etc.",
    "Include biophilic features and techniques in the design of buildings and structures including green roofs, green walls, green shading, rammed earth, mycelium, etc.",
    "Maximize landscape areas including native and adaptive species to reduce water consumption.",
    "Minimize the heat island effect by providing large landscape areas, and high reflectance materials on façades, roofs, structures, and hardscape areas."
  ]

[el_7_provisional_scheme_criterion, el_7_final_scheme_criterion].each do |criterion|
  el_7_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_7_design_requirements = 
  [
    "Site Layouts showing shades at public gatherings and queuing areas",
    "Architectural typical details for Green Roofs and Walls",
    "Landscape schedule",
    "Architectural Layouts",
    "Tentative Material Selection"
  ]

el_7_design_requirements.each.with_index(1) do |ci, i|
  rt_for_el_7_scheme_criterion = nil

  rt_for_el_7_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_design
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_7_scheme_criterion, 
    scheme_criterion: el_7_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_7_scheme_criterion, 
    scheme_criterion: el_7_final_scheme_criterion
  )
end

el_7_construction_requirements = 
  [
    "Photos of Shades",
    "Update Layouts (if applicable)",
    "Photos of the Green roofs, green walls, and green architectural features",
    "Photos of planted species",
    "Material Approval Requests",
    "Photos of the hardscape and vegetation"
  ]

el_7_construction_requirements.each.with_index(1) do |ci, i|
  rt_for_el_7_scheme_criterion = nil
  rt_for_el_7_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_construction
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_7_scheme_criterion, 
    scheme_criterion: el_7_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_7_scheme_criterion, 
    scheme_criterion: el_7_final_scheme_criterion
  )
end

# --------------------------------- EL.8 ----------------------------------
el_8_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Heritage & Cultural Identity", 
    number: 8, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_8_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_8_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_8_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_8_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Heritage & Cultural Identity", 
    number: 8, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_8_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_8_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_8_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_8_criteria_information = 
  [
    "Consider design strategies that enhance, strengthen, and reflect the heritage and cultural identity of the region.",
    "Consider architectural design expressions that harmonize with the cultural values and traditions of the people.",
    "Design landscape and plant-based ornamental features that harmonize with cultural values."
  ]

[el_8_provisional_scheme_criterion, el_8_final_scheme_criterion].each do |criterion|
  el_8_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_8_design_requirements = 
  [
    "Heritage and Cultural Identity Plan that stipulates guidelines for architectural and branding design",
    "Architectural Details and Elevations showing the cultural features of the Design",
    "Landscape Layouts",
    "Landscape Details"
  ]

el_8_design_requirements.each.with_index(1) do |ci, i|
  rt_for_el_8_scheme_criterion = nil

  rt_for_el_8_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_design
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_8_scheme_criterion, 
    scheme_criterion: el_8_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_8_scheme_criterion, 
    scheme_criterion: el_8_final_scheme_criterion
  )
end

el_8_construction_requirements = 
  [
    "Photos of Building elevations",
    "Photos of Landscape features"
  ]

el_8_construction_requirements.each.with_index(1) do |ci, i|
  rt_for_el_8_scheme_criterion = nil
  rt_for_el_8_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_construction
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_8_scheme_criterion, 
    scheme_criterion: el_8_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_8_scheme_criterion, 
    scheme_criterion: el_8_final_scheme_criterion
  )
end

# --------------------------------- EL.9 ----------------------------------
el_9_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Sustainable Materials", 
    number: 9, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_9_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_9_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_9_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_9_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Sustainable Materials", 
    number: 9, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_9_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_9_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_9_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_9_criteria_information = 
  [
    "Procure locally sourced materials to reduce the transportation distance which will mitigate the environmental impacts of transportation.",
    "Construct using reused materials for temporary buildings.",
    "Use construction materials with recycled content.",
    "Consider utilizing reused materials for fit-out, wayfinding, or safety signage.",
    "Use fit-out materials with recycled content."
  ]

[el_9_provisional_scheme_criterion, el_9_final_scheme_criterion].each do |criterion|
  el_9_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_9_design_requirements = 
  [
    "Tentative Material Schedule, showing the origin",
    "Tentative Material Schedule of the salvaged materials",
    "Photos of the salvaged materials",
    "Tentative Material Schedule, showing the recycled content percentage",
    "Tentative Material Schedule of the salvaged materials",
    "Photos of the salvaged materials",
    "Tentative Material Schedule, showing the recycled content percentage"
  ]

el_9_design_requirements.each.with_index(1) do |ci, i|
  rt_for_el_9_scheme_criterion = nil

  rt_for_el_9_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_design
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_9_scheme_criterion, 
    scheme_criterion: el_9_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_9_scheme_criterion, 
    scheme_criterion: el_9_final_scheme_criterion
  )
end

el_9_construction_requirements = 
  [
    "Material Approval Requests",
    "Photos of the installed material on the construction site",
    "Manufacturer Specification showing the recycled percentage",
  ]

el_9_construction_requirements.each.with_index(1) do |ci, i|
  rt_for_el_9_scheme_criterion = nil
  rt_for_el_9_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_construction
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_9_scheme_criterion, 
    scheme_criterion: el_9_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_9_scheme_criterion, 
    scheme_criterion: el_9_final_scheme_criterion
  )
end

# --------------------------------- EL.10 ----------------------------------
el_10_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Materials Eco-Labelling", 
    number: 10, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_10_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_10_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_10_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_10_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Materials Eco-Labelling", 
    number: 10, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_10_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_10_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_10_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_10_criteria_information = 
  [
    "Procure materials with GSAS-approved certification for eco-labeling demonstrating sustainable features of the material.",
    "Procure materials with GSAS-approved certification for environmental product declarations.",
    "Procure materials with GSAS-approved certification  for responsible sourcing.",
    "Procure materials with GSAS-approved certification  for low volatile organic compounds content."
  ]

[el_10_provisional_scheme_criterion, el_10_final_scheme_criterion].each do |criterion|
  el_10_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_10_design_requirements = 
  [
    "Tentative Material Schedule, showing Eco-labeled materials",
    "Tentative Material Schedule, showing EPD Eco-labeled materials",
    "Tentative Material Schedule, showing RS Eco-labeled materials",
    "Tentative Material Schedule, showing Low-VOC Eco-labeled materials"
  ]

el_10_design_requirements.each.with_index(1) do |ci, i|
  rt_for_el_10_scheme_criterion = nil

  rt_for_el_10_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_design
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_10_scheme_criterion, 
    scheme_criterion: el_10_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_10_scheme_criterion, 
    scheme_criterion: el_10_final_scheme_criterion
  )
end

el_10_construction_requirements = 
  [
    "Material Approval Requests",
    "Eco-Label certificates of the materials",
    "Material Approval Requests",
    "EPD Eco-Label certificates of the materials",
    "Material Approval Requests",
    "RS Eco-Label certificates of the materials",
    "Material Approval Requests",
    "Low VOC Eco-Label certificates of the materials"
  ]

el_10_construction_requirements.each.with_index(1) do |ci, i|
  rt_for_el_10_scheme_criterion = nil
  rt_for_el_10_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_construction
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_10_scheme_criterion, 
    scheme_criterion: el_10_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_10_scheme_criterion, 
    scheme_criterion: el_10_final_scheme_criterion
  )
end

# --------------------------------- EL.11 ----------------------------------
el_11_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Supply Chain & Exhibitors Management", 
    number: 11, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_11_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_11_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_11_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_11_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Supply Chain & Exhibitors Management", 
    number: 11, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_11_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_11_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_11_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_11_criteria_information = 
  [
    "Develop and implement a sustainable procurement program for materials and products."
  ]

[el_11_provisional_scheme_criterion, el_11_final_scheme_criterion].each do |criterion|
  el_11_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_11_design_requirements = 
  [
    "Sustainable Procurement Program"
  ]

el_11_design_requirements.each.with_index(1) do |ci, i|
  rt_for_el_11_scheme_criterion = nil

  rt_for_el_11_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_design
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_11_scheme_criterion, 
    scheme_criterion: el_11_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_11_scheme_criterion, 
    scheme_criterion: el_11_final_scheme_criterion
  )
end

el_11_operation_requirements = 
  [
    "Sustainable Procurement Program for Operations activities"
  ]

el_11_operation_requirements.each.with_index(1) do |ci, i|
  rt_for_el_11_scheme_criterion = nil
  rt_for_el_11_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_operation
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_11_scheme_criterion, 
    scheme_criterion: el_11_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_11_scheme_criterion, 
    scheme_criterion: el_11_final_scheme_criterion
  )
end

# --------------------------------- EL.12 ----------------------------------
el_12_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Waste Management", 
    number: 12, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_12_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_12_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_12_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_12_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Waste Management", 
    number: 12, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_12_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_12_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_12_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_12_criteria_information = 
  [
    "Reuse waste generated during construction on site. Surplus concrete, worn-out wood, and steel scrap have many possibilities for reuse on-site.",
    "Segregate construction and demolition waste generated at source to enable at least 75% of recycling rate (by weight or volume).",
    "Consider collecting mixed construction waste and transferring it to an onsite waste segregation area for a specialized crew of workers to segregate it into different streams (concrete, steel scrap, plastic, paper & cardboard, wood, food, and general waste).",
    "Order materials in bulk, where possible, to reduce packaging. Alternatively, purchase materials with minimum packaging.",
    "Establish and maintain proper material storage  facilities and practices to avoid overordering and  thus reduce waste.",
    "Minimize the use of single-use plastics. Consider implementing returnable schemes with rewards that encourage the use of alternative materials like eco-bags and refillable bottles.",
    "Place adequate numbers and sizes of containers  (skips, bins, or similar).",
    "Segregate waste generated during the event at source to enable at least 65% of the recycling rate (by weight or volume).",
    "Consider collecting at least food waste, recyclables, and general waste into different containers and transferring it to an on-site waste segregation area for a specialized crew of workers to segregate it into different streams (metals, plastic, paper &  cardboard, food, and general waste).",
    "Ensure segregation efficiency at the source. A crew of volunteers could be utilized to inform visitors at the collection points on the correct bin for their waste.",
    "Set up a reward system to encourage waste segregation. Install collection points of cans and bottles to reward visitors with discounts at food &  beverage or retail shops on site.",
    "Collect and segregate hazardous waste such as oil and clinic disposal separately from other waste streams.",
    "Arrange transportation of waste with licensed  Waste Management Contractors (WMCs).",
    "Segregate organic waste (food and green waste) for  composting at on-site or off-site composting  facilities.",
    "Arrange recycling of different waste streams with licensed recycling facilities.",
    "Ensure safe removal/disposal at an authorized  landfill for non-recyclable waste.",
    "Implement a robust waste tracking system to ensure the waste generated ends up at the designated recycling or disposal facility. Records of quantities per waste stream must be kept.",
    "Send bulky waste items to organizations that are willing to repair and/or reuse them. Find further reuse for furniture and equipment within other projects, either by selling, donating, or reusing within the same organization in a different project.",
  ]

[el_12_provisional_scheme_criterion, el_12_final_scheme_criterion].each do |criterion|
  el_12_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_12_construction_requirements = 
  [
    "Photos of reused material on site",
    "Waste tracking table and submittals included under the waste tracking system assessment principle",
    "Photos of the waste collection area",
    "Photos of materials in bulk and low-packaged materials on site",
    "Photos of laydown areas and warehouses",
    "Photos of the waste collection area",
    "Photos of hazardous waste containers",
    "Permits of specialized waste subcontractors",
    "Photos of organic waste collection containers",
    "All monthly disposal logs/invoices indicating the type of waste",
    "Disposal WTNs",
    "One collection WTN per type of waste and month",
    "All monthly collection logs/invoices indicating the quantities per type of waste",
    "One disposal WTN per type of waste and month",
    "All monthly disposal logs/invoices indicating the quantities per type of waste"
  ]

el_12_construction_requirements.each.with_index(1) do |ci, i|
  rt_for_el_12_scheme_criterion = nil
  rt_for_el_12_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_construction
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_12_scheme_criterion, 
    scheme_criterion: el_12_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_12_scheme_criterion, 
    scheme_criterion: el_12_final_scheme_criterion
  )
end

el_12_operation_requirements = 
  [
    "Photos of materials in bulk and low-packaged materials on site",
    "Photos of storage facilities",
    "Photos of alternative materials used on site",
    "Photos of returnable schemes",
    "Photos of the waste collection area",
    "Waste tracking table and submittals included under the waste tracking systm assessment principle",
    "Photos of the waste collection area",
    "Photos of waste collection bins",
    "Photos of volunteers at waste collection points",
    "Photos of collection points",
    "Photos of hazardous waste containers",
    "Permits of specialized waste subcontractors",
    "Photos of organic waste collection containers",
    "All monthly disposal logs/invoices indicating the type of waste",
    "Disposal WTNs",
    "One collection WTN per type of waste and month",
    "All monthly collection logs/invoices indicating the quantities per type of waste",
    "One disposal WTN per type of waste and month",
    "All monthly disposal logs/invoices indicating the quantities per type of waste"
  ]

el_12_operation_requirements.each.with_index(1) do |ci, i|
  rt_for_el_12_scheme_criterion = nil
  rt_for_el_12_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_operation
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_12_scheme_criterion, 
    scheme_criterion: el_12_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_12_scheme_criterion, 
    scheme_criterion: el_12_final_scheme_criterion
  )
end

el_12_dismantling_requirements = 
  [
    "Waste tracking table and submittals included under the waste tracking system assessment principle",
    "Photos of the waste collection area",
    "Permits of specialized waste subcontractors",
    "Photos of organic waste collection containers",
    "All monthly disposal logs/invoices indicating the type of waste",
    "Disposal WTNs",
    "One collection WTN per type of waste and month",
    "All monthly collection logs/invoices indicating the quantities per type of waste",
    "One disposal WTN per type of waste and month",
    "All monthly disposal logs/invoices indicating the quantities per type of waste",
    "Disposal WTNs"
  ]

el_12_dismantling_requirements.each.with_index(1) do |ci, i|
  rt_for_el_12_scheme_criterion = nil
  rt_for_el_12_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_dismantling
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_12_scheme_criterion, 
    scheme_criterion: el_12_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_12_scheme_criterion, 
    scheme_criterion: el_12_final_scheme_criterion
  )
end

# --------------------------------- EL.13 ----------------------------------
el_13_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Facility Management", 
    number: 13, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_13_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_13_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_13_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_13_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Facility Management", 
    number: 13, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_13_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_13_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_13_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_13_criteria_information = 
  [
    "Develop and implement a facility maintenance plan. The plan must include a schedule of testing and inspections to ensure that the facilities are operated safely and efficiently. It may contain several maintenance plans for different facility systems,  like lighting, fire safety, air conditioning, etc.",
    "Ensure proper housekeeping including janitorial services, help desk support, storing facility, fire safety, security, environment, and health & safety,  etc.",
    "Apply a green cleaning policy, minimizing the use of chemicals potentially hazardous to the environment and human health.",
    "Ensure data collection for energy and water consumption, chemicals use, and waste production."
  ]

[el_13_provisional_scheme_criterion, el_13_final_scheme_criterion].each do |criterion|
  el_13_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_13_construction_requirements = 
  [
    "Facility Maintenance Plan",
    "Sample Inspection Report per each area of maintenance",
    "PEvidence (Logs, attendance sheets,  task orders, complaint forms) of FM activities: housekeeping, help desk support, storing facility, fire safety, security, environment, and health & safety",
    "Purchase Orders, or Invoices",
    "Photos of the Chemical Storage Facility",
    "Photos of Ecological labels of the products",
    "Energy and Water Consumption Logs (Weekly)",
    "Energy and Water bills",
    "Chemicals use logs",
    "Waste collection invoices"
  ]

el_13_construction_requirements.each.with_index(1) do |ci, i|
  rt_for_el_13_scheme_criterion = nil
  rt_for_el_13_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_construction
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_13_scheme_criterion, 
    scheme_criterion: el_13_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_13_scheme_criterion, 
    scheme_criterion: el_13_final_scheme_criterion
  )
end

# --------------------------------- EL.14 ----------------------------------
el_14_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Health & safety Management", 
    number: 14, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_14_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_14_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_14_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_14_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Health & safety Management", 
    number: 14, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_14_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_14_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_14_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_14_criteria_information = 
  [
    "Develop and implement a health & safety plan during construction, including an emergency plan.",
    "Develop and implement a health & safety plan during the event, including an emergency plan.",
    "Provide health and safety training to workers and volunteers.",
    "Develop and implement a heat stress program including monitoring of the humidity index every thirty minutes. Also, implement different degrees of hydration and rest measures depending on the heat and humidity index."
  ]

[el_14_provisional_scheme_criterion, el_14_final_scheme_criterion].each do |criterion|
  el_14_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_14_construction_requirements = 
  [
    "health & safety plan",
    "Photos showing the implementation of the main measures",
    "Content Slides",
    "Attendance sheet, making sure the targeted audience attended",
    "Heat and Humidity Index records",
    "Heat stress plan, showing actions for different ranges of heat and humidity index"
  ]

el_14_construction_requirements.each.with_index(1) do |ci, i|
  rt_for_el_14_scheme_criterion = nil
  rt_for_el_14_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_construction
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_14_scheme_criterion, 
    scheme_criterion: el_14_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_14_scheme_criterion, 
    scheme_criterion: el_14_final_scheme_criterion
  )
end

el_14_operation_requirements = 
  [
    "health & safety plan",
    "Photos showing the implementation of the main measures",
    "Content Slides",
    "Attendance sheet, making sure the targeted audience attended",
    "Heat and Humidity Index records",
    "Heat stress plan, showing actions for different ranges of heat and humidity index"
  ]

el_14_operation_requirements.each.with_index(1) do |ci, i|
  rt_for_el_14_scheme_criterion = nil
  rt_for_el_14_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_operation
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_14_scheme_criterion, 
    scheme_criterion: el_14_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_14_scheme_criterion, 
    scheme_criterion: el_14_final_scheme_criterion
  )
end

el_14_dismantling_requirements = 
  [
    "health & safety plan",
    "Photos showing the implementation of the main measures",
    "Content Slides",
    "Attendance sheet, making sure the targeted audience attended",
    "Heat and Humidity Index records",
    "Heat stress plan, showing actions for different ranges of heat and humidity index"
  ]

el_14_dismantling_requirements.each.with_index(1) do |ci, i|
  rt_for_el_14_scheme_criterion = nil
  rt_for_el_14_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_dismantling
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_14_scheme_criterion, 
    scheme_criterion: el_14_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_14_scheme_criterion, 
    scheme_criterion: el_14_final_scheme_criterion
  )
end

# --------------------------------- EL.15 ----------------------------------
el_15_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Transportation Management", 
    number: 15, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_15_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_15_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_15_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_15_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Transportation Management", 
    number: 15, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_15_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_15_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_15_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_15_criteria_information = 
  [
    "Provide adequate local transportation services or shuttle bus services to and from destination areas within the festival site.",
    "Provide shuttle transportation from the development to nearby transit hubs and airports.",
    "Ensure the availability of nearby public transportation that can support the capacity of the  staff and guests.",
    "Ensure proper display of routes for public bus stops, rail, and metro stations.",
    "Include within the event vehicle fleet alternative vehicles other than fossil-fueled including electric buses, cars, golf carts, scooters, etc.",
    "Offer discounts/incentives to the visitors for using public transportation to reach the event site. Consider discounts on event tickets, food, and beverage, retail shops, etc. As incentives, consider giveaways like merchandise items in line with sustainability, like plants. Engage the local public transportation administration, sponsors, and F&B companies to set up rewarding systems beneficial for all.",
    "Provide, where possible, separate lanes for both pedestrian and bicycle riders."
  ]

[el_15_provisional_scheme_criterion, el_15_final_scheme_criterion].each do |criterion|
  el_15_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_15_design_requirements = 
  [
    "Landscape Layouts"
  ]

el_15_design_requirements.each.with_index(1) do |ci, i|
  rt_for_el_15_scheme_criterion = nil

  rt_for_el_15_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_design
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_15_scheme_criterion, 
    scheme_criterion: el_15_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_15_scheme_criterion, 
    scheme_criterion: el_15_final_scheme_criterion
  )
end

el_15_construction_requirements = 
  [
    "Photos of designated lanes",
    "Updated Landscape Layouts"
  ]

el_15_construction_requirements.each.with_index(1) do |ci, i|
  rt_for_el_15_scheme_criterion = nil
  rt_for_el_15_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_construction
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_15_scheme_criterion, 
    scheme_criterion: el_15_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_15_scheme_criterion, 
    scheme_criterion: el_15_final_scheme_criterion
  )
end

el_15_operation_requirements = 
  [
    "Photos for local transportation services",
    "Map of the local routes",
    "Maps of the transportation routes",
    "Schedule for the service frequency",
    "Photos of the vehicles and stops",
    "Maps of the public transportation routes",
    "Schedule for the transportation frequency",
    "Photos of the vehicles and stops",
    "Maps for the signage used for visitor guidance",
    "Photos for the signage",
    "Photos of facilities used",
    "List of the vehicles indicating the alternative ones",
    "Discount/Incentive Program",
    "Communication with visitors (media, social media content, posters, brochures, etc)"
  ]

el_15_operation_requirements.each.with_index(1) do |ci, i|
  rt_for_el_15_scheme_criterion = nil
  rt_for_el_15_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_operation
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_15_scheme_criterion, 
    scheme_criterion: el_15_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_15_scheme_criterion, 
    scheme_criterion: el_15_final_scheme_criterion
  )
end

# --------------------------------- EL.16 ----------------------------------
el_16_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Landscape Maintenance", 
    number: 16, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_16_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_16_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_16_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_16_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Landscape Maintenance", 
    number: 16, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_16_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_16_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_16_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_16_criteria_information = 
  [
    "Develop a framework for monitoring the landscape and irrigation maintenance procedures and progress.",
    "Develop a detailed maintenance schedule to be carried out, considering the present flora and fauna and their requirements.",
    "Utilize compost or fertilizers with a low environmental footprint.",
    "Minimize the use of pesticides, especially those containing toxic chemicals, and consider utilization of non-toxic nature-based pesticides."
  ]

[el_16_provisional_scheme_criterion, el_16_final_scheme_criterion].each do |criterion|
  el_16_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_16_design_requirements = 
  [
    "Landscape and Irrigation maintenance framework"
  ]

el_16_design_requirements.each.with_index(1) do |ci, i|
  rt_for_el_16_scheme_criterion = nil

  rt_for_el_16_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_design
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_16_scheme_criterion, 
    scheme_criterion: el_16_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_16_scheme_criterion, 
    scheme_criterion: el_16_final_scheme_criterion
  )
end

el_16_operation_requirements = 
  [
    "Landscape flora and fauna framework",
    "Purchase Orders, or Invoices",
    "Photos of the used products",
    "Purchase Orders, or Invoices",
    "Photos of the used products"
  ]

el_16_operation_requirements.each.with_index(1) do |ci, i|
  rt_for_el_16_scheme_criterion = nil
  rt_for_el_16_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_operation
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_16_scheme_criterion, 
    scheme_criterion: el_16_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_16_scheme_criterion, 
    scheme_criterion: el_16_final_scheme_criterion
  )
end

# --------------------------------- EL.17 ----------------------------------
el_17_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Catering", 
    number: 17, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_17_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_17_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_17_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_17_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Catering", 
    number: 17, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_17_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_17_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_17_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_17_criteria_information = 
  [
    "Select locally-sourced suppliers and catering services to promote the local economy and mitigate the carbon footprint of the food & beverage options.",
    "Implement measures to reduce the amount of food packaging of any material to avoid waste generation.",
    "Implement measures to reduce the use of single-use plastics, and avoid unnecessary plastic packaging,  bottles, bags, cutlery, plates, cups, stirrers, straws, etc.",
    "Use reusable, biodegradable, or compostable alternative materials to plastic for single-use items like packaging, bottles, bags, plates, cutlery,  cups, straws, stirrers, etc. Avoid the use of photodegradable and oxo-degradable materials that could break into microplastics.",
    "Facilitate the use of reusable cups. Consider the installation of water refill stations on site and offering reusable cups and a reward system for returning them to collection points for further cleaning and reuse.",
    "Ensure all food and beverage packaging is fully recyclable.",
    "Implement measures to reduce food waste. Plan the food procurement according to a realistic demand and take into consideration the expiration dates of the edible products. Avoid serving too large portions that result in food waste.",
    "Arrange for the segregation and collection of food waste on-site for composting either at on or offsite facilities.",
    "Ensure a wide range of organic food offerings on-site to promote a healthier and environmentally friendly diet.",
    "Ensure a wide range of vegetarian food offerings on site to accommodate the needs of vegetarian visitors and minimize the associated carbon footprint of food.",
    "Arrange for the collection of surplus food suitable for consumption and donation to local charity organizations.",
    "Keep the food offerings within specific designated areas to avoid waste spreading and facilitate an easier waste collection procedure."
  ]

[el_17_provisional_scheme_criterion, el_17_final_scheme_criterion].each do |criterion|
  el_17_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_17_design_requirements = 
  [
    "Site Layout, highlighting the designated areas"
  ]

el_17_design_requirements.each.with_index(1) do |ci, i|
  rt_for_el_17_scheme_criterion = nil

  rt_for_el_17_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_design
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_17_scheme_criterion, 
    scheme_criterion: el_17_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_17_scheme_criterion, 
    scheme_criterion: el_17_final_scheme_criterion
  )
end

el_17_construction_requirements = 
  [
    "Photos of the designated areas"
  ]

el_17_construction_requirements.each.with_index(1) do |ci, i|
  rt_for_el_17_scheme_criterion = nil
  rt_for_el_17_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_construction
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_17_scheme_criterion, 
    scheme_criterion: el_17_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_17_scheme_criterion, 
    scheme_criterion: el_17_final_scheme_criterion
  )
end

el_17_operation_requirements = 
  [
    "Exercpts of contracts with suppliers, showing scopes",
    "Commercial Registrations",
    "Description of measures taken to reduce packaging",
    "Photos of served food",
    "Description of measures taken to reduce plastics",
    "Product description for the packaging materials",
    "Photos of the implemented measures",
    "Description of measures taken to replace single-use plastic",
    "Photos of alternative materials",
    "Description of measures taken to use reusable cups",
    "Photos of the implemented measures",
    "Excerpts from contracts with food suppliers, showing the requirement for packaging recyclability",
    "Photos of recyclability labels on the packaging",
    "Description of measures taken to reduce food waste",
    "Photos of the implemented measures",
    "Photos of food waste bins, skips, or containers",
    "Photos of the on-site composting facility (if any)",
    "For off-site, One sample collection waste transfer note (WTN) per month",
    "For off-site, One sample disposal WTN at the off-site composting facility per month",
    "For off-site, All monthly invoices from the waste hauler",
    "For off-site, All monthly certificates from the off-site composting facility",
    "Excerpts from contracts",
    "Samples of food menus",
    "Photos of served food",
    "Excerpts from contracts",
    "Samples of food menus",
    "Photos of served food",
    "Agreements with Charity organizations for food surplus collection",
    "Samples of food collection receipts",
    "Photos of food collection",
  ]

el_17_operation_requirements.each.with_index(1) do |ci, i|
  rt_for_el_17_scheme_criterion = nil
  rt_for_el_17_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_operation
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_17_scheme_criterion, 
    scheme_criterion: el_17_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_17_scheme_criterion, 
    scheme_criterion: el_17_final_scheme_criterion
  )
end

# --------------------------------- EL.18 ----------------------------------
el_18_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Pollution", 
    number: 18, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_18_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_18_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_18_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_18_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Pollution", 
    number: 18, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_18_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_18_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_18_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_18_criteria_information = 
  [
    "Implement measures to reduce noise pollution affecting the neighborhood, visitors, and staff across all the phases of the event.",
    "Implement measures to reduce light pollution affecting the neighborhood across all the phases of the event.",
    "Implement measures to reduce air pollution across all the phases of the event.",
    "Implement measures to reduce ground pollution by controlling fuel and oil spillage from tanks, generators, and stationary machinery, and toxic spillage from chemicals stores.",
    "Implement measures to reduce ground pollution by installing proper concrete washout facilities for the trucks to be cleaned before exiting the site."
  ]

[el_18_provisional_scheme_criterion, el_18_final_scheme_criterion].each do |criterion|
  el_18_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_18_design_requirements = 
  [
    "Layout showing noise barriers, hoarding, or buffer zones against sensitive receptors",
    "Description of measures considered for noise pollution",
    "Lightings Layouts",
    "Description of measures considered for light pollution",
    "Tentative Material Selection",
    "Layout showing implemented measures",
    "Description of measures considered for dust pollution"
  ]

el_18_design_requirements.each.with_index(1) do |ci, i|
  rt_for_el_18_scheme_criterion = nil

  rt_for_el_18_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_design
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_18_scheme_criterion, 
    scheme_criterion: el_18_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_18_scheme_criterion, 
    scheme_criterion: el_18_final_scheme_criterion
  )
end

el_18_construction_requirements = 
  [
    "Photos of noise barriers, hoarding, or buffer zones against sensitive receptors",
    "Photos for temporary measures during construction",
    "Material Approval Requests",
    "Photos of lighting fixtures during nighttime",
    "Photos for temporary measures during construction nighttime",
    "Photos of implemented measures",
    "Photos for temporary measures during construction",
    "Description of measures considered for ground pollution, to control oil and fuel spillage",
    "Photos of the implemented measures",
    "Photos of concrete washout"
  ]

el_18_construction_requirements.each.with_index(1) do |ci, i|
  rt_for_el_18_scheme_criterion = nil
  rt_for_el_18_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_construction
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_18_scheme_criterion, 
    scheme_criterion: el_18_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_18_scheme_criterion, 
    scheme_criterion: el_18_final_scheme_criterion
  )
end

el_18_operation_requirements = 
  [
    "Photos of noise barriers, hoarding, or buffer zones against sensitive receptors",
    "Photos of lighting fixtures during nighttime",
    "Photos of implemented measures",
    "Photos of the implemented measures"
  ]

el_18_operation_requirements.each.with_index(1) do |ci, i|
  rt_for_el_18_scheme_criterion = nil
  rt_for_el_18_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_operation
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_18_scheme_criterion, 
    scheme_criterion: el_18_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_18_scheme_criterion, 
    scheme_criterion: el_18_final_scheme_criterion
  )
end

el_18_dismantling_requirements = 
  [
    "Photos for temporary measures during dismantling, like noise barriers, hoarding, or buffer zones against sensitive receptors",
    "Photos for temporary measures during dismantling nighttime",
    "Photos for temporary measures during the dismantling",
    "Description of measures considered for ground pollution, to control oil and fuel spillage",
    "Photos of the implemented measures"
  ]

el_18_dismantling_requirements.each.with_index(1) do |ci, i|
  rt_for_el_18_scheme_criterion = nil
  rt_for_el_18_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_dismantling
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_18_scheme_criterion, 
    scheme_criterion: el_18_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_18_scheme_criterion, 
    scheme_criterion: el_18_final_scheme_criterion
  )
end

# --------------------------------- EL.19 ----------------------------------
el_19_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Carbon Footprint", 
    number: 19, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_19_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_19_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_19_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_19_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Carbon Footprint", 
    number: 19, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_19_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_19_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_19_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_19_criteria_information = 
  [
    "Calculate Scope 1 and Scope 2 emissions across all the phases of the event. Develop and implement a  GHG emissions mitigation plan."
  ]

[el_19_provisional_scheme_criterion, el_19_final_scheme_criterion].each do |criterion|
  el_19_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_19_construction_requirements = 
  [
    "Fuel consumption logs of generators and construction equipment",
    "Electricity bills from utility provider (if any)",
    "Refrigerant consumption"
  ]

el_19_construction_requirements.each.with_index(1) do |ci, i|
  rt_for_el_19_scheme_criterion = nil
  rt_for_el_19_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_construction
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_19_scheme_criterion, 
    scheme_criterion: el_19_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_19_scheme_criterion, 
    scheme_criterion: el_19_final_scheme_criterion
  )
end

el_19_operation_requirements = 
  [
    "Fuel consumption logs of generators, operation equipment, and vehicle fleet",
    "Electricity bills from utility provider (if any)",
    "Refrigerant consumption"
  ]

el_19_operation_requirements.each.with_index(1) do |ci, i|
  rt_for_el_19_scheme_criterion = nil
  rt_for_el_19_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_operation
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_19_scheme_criterion, 
    scheme_criterion: el_19_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_19_scheme_criterion, 
    scheme_criterion: el_19_final_scheme_criterion
  )
end

el_19_dismantling_requirements = 
  [
    "Fuel consumption logs of generators and dismantling equipment",
    "Electricity bills from utility provider (if any)",
    "Refrigerant consumption"
  ]

el_19_dismantling_requirements.each.with_index(1) do |ci, i|
  rt_for_el_19_scheme_criterion = nil
  rt_for_el_19_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_dismantling
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_19_scheme_criterion, 
    scheme_criterion: el_19_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_19_scheme_criterion, 
    scheme_criterion: el_19_final_scheme_criterion
  )
end

# --------------------------------- EL.20 ----------------------------------
el_20_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Sustainability Awareness", 
    number: 20, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_20_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_20_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_20_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_20_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Sustainability Awareness", 
    number: 20, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_20_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_20_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_20_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_20_criteria_information = 
  [
    "Identify communication channels, preferably avoiding the use of paper to minimize the carbon footprint.",
    "Communicate to the visitors the sustainability features of the event for them to make the best use  of them.",
    "Program a series of events (forums, workshops,  lectures, contests, etc.) to raise sustainability awareness among visitors.",
    "Engage the participation of schools and local community organizations in the sustainability awareness activities.",
    "Educate the visitors and participants on the environmental and health benefits of using public transportation and alternative means of transport other than fossil-fueled.",
    "Arrange knowledge-sharing activities to build capacity in the local community on the theme of the event."
  ]

[el_20_provisional_scheme_criterion, el_20_final_scheme_criterion].each do |criterion|
  el_20_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_20_design_requirements = 
  [
    "Communication Plan",
    "Correspondence with stakeholders"
  ]

el_20_design_requirements.each.with_index(1) do |ci, i|
  rt_for_el_20_scheme_criterion = nil

  rt_for_el_20_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_design
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_20_scheme_criterion, 
    scheme_criterion: el_20_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_20_scheme_criterion, 
    scheme_criterion: el_20_final_scheme_criterion
  )
end

el_20_operation_requirements = 
  [
    "Evidence of communication, including slides, posters, social media content, video, etc",
    "Schedule of events",
    "Photos of events",
    "Correspondence with schools",
    "Schedule of events",
    "Photos of events",
    "Evidence of communication, including slides, posters, social media content, video, etc",
    "Schedule of events"
  ]

el_20_operation_requirements.each.with_index(1) do |ci, i|
  rt_for_el_20_scheme_criterion = nil
  rt_for_el_20_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_operation
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_20_scheme_criterion, 
    scheme_criterion: el_20_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_20_scheme_criterion, 
    scheme_criterion: el_20_final_scheme_criterion
  )
end

# --------------------------------- EL.21 ----------------------------------
el_21_provisional_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Legacy", 
    number: 21, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_provisional_scheme_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_21_provisional_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_21_provisional_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_21_provisional_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_21_final_scheme_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "Legacy", 
    number: 21, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: el_final_scheme_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_21_final_scheme_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_21_final_scheme_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: el_21_final_scheme_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

el_21_criteria_information = 
  [
    "Ensure the future usability of the infrastructure built for the event.",
    "Design temporary buildings to include standard components and assemblies to enhance the possibilities for future reuse."
  ]

[el_21_provisional_scheme_criterion, el_21_final_scheme_criterion].each do |criterion|
  el_21_criteria_information.each.with_index(1) do |ci, i|
    SchemeCriterionText.find_or_create_by(
      scheme_criterion: criterion,
      display_weight: i, 
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
end

# Create Requirements
el_21_design_requirements = 
  [
    "Infrastructure Layouts",
    "Description of infrastructure usability measures",
    "Details for modular designed components and assemblies"
  ]

el_21_design_requirements.each.with_index(1) do |ci, i|
  rt_for_el_21_scheme_criterion = nil

  rt_for_el_21_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_design
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_21_scheme_criterion, 
    scheme_criterion: el_21_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_21_scheme_criterion, 
    scheme_criterion: el_21_final_scheme_criterion
  )
end

el_21_construction_requirements = 
  [
    "Updated Infrastructure Layouts"
  ]

el_21_construction_requirements.each.with_index(1) do |ci, i|
  rt_for_el_21_scheme_criterion = nil
  rt_for_el_21_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_construction
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_21_scheme_criterion, 
    scheme_criterion: el_21_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_21_scheme_criterion, 
    scheme_criterion: el_21_final_scheme_criterion
  )
end

el_21_dismantling_requirements = 
  [
    "Updated Infrastructure Layouts",
    "Photos of the final condition of the site",
    "Logs of dismantled components",
    "Photos of the final condition of the site",
    "Evidence of component storage"
  ]

el_21_dismantling_requirements.each.with_index(1) do |ci, i|
  rt_for_el_21_scheme_criterion = nil
  rt_for_el_21_scheme_criterion = 
    Requirement.find_or_create_by(
      name: ci, 
      display_weight: i,
      requirement_category: requirement_category_for_dismantling
    )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_21_scheme_criterion, 
    scheme_criterion: el_21_provisional_scheme_criterion
  )
  SchemeCriteriaRequirement.find_or_create_by(
    requirement: rt_for_el_21_scheme_criterion, 
    scheme_criterion: el_21_final_scheme_criterion
  )
end

# Licences for Service Providers
# Ecoleaf
Licence.find_or_create_by(
  licence_type: 'ServiceProviderLicence',
  display_name: 'GSAS ECOLEAF',
  display_weight: 17,
  title: 'GSAS ECOLEAF',
  description: 'GSAS Ecoleaf Service Provider',
  certificate_type: Certificate.certificate_types[:ecoleaf_type],
  schemes: ['Expo Site']
)

# Licences for Certified Professional
# Ecoleaf - CGP
Licence.find_or_create_by(
  licence_type: 'CgpLicence',
  display_name: 'GSAS CGP ECOLEAF, ASSOCIATE',
  display_weight: 18,
  title: 'GSAS ECOLEAF - CGP',
  description: 'GSAS Ecoleaf Certified Green Professional',
  certificate_type: Certificate.certificate_types[:ecoleaf_type],
  applicability: Licence.applicabilities[:check_list],
  schemes: ['Expo Site']
)

# Ecoleaf - CEP
Licence.find_or_create_by(
  licence_type: 'CepLicence',
  display_name: 'GSAS CEP ECOLEAF',
  display_weight: 19,
  title: 'GSAS ECOLEAF - CEP',
  description: 'GSAS Ecoleaf Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:ecoleaf_type],
  applicability: Licence.applicabilities[:check_list],
  schemes: ['Expo Site']
)

