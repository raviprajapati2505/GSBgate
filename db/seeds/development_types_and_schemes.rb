# ---------------------------- energy_centers_efficiency ----------------------------
provisional_energy_centers_efficiency_dt = 
  DevelopmentType.find_or_create_by!(
    display_weight: 1, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:provisional_energy_centers_efficiency], 
      certificate_type: Certificate.certificate_types[:energy_centers_efficiency_type], 
      assessment_stage: Certificate.assessment_stages[:energy_centers_efficiency_stage], 
      gsb_version: "2023" 
    ), 
    mixable: false, 
    name: 'Typology'
  )
final_energy_centers_efficiency_dt = 
  DevelopmentType.find_or_create_by!(
    display_weight: 2, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:final_energy_centers_efficiency], 
      certificate_type: Certificate.certificate_types[:energy_centers_efficiency_type], 
      assessment_stage: Certificate.assessment_stages[:energy_centers_efficiency_stage], 
      gsb_version: "2023"
    ), 
    mixable: false, 
    name: 'Typology'
  )

provisional_energy_centers_efficiency_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:provisional_energy_centers_efficiency], 
    certificate_type: Certificate.certificate_types[:energy_centers_efficiency_type], 
    renovation: false
  )
final_energy_centers_efficiency_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:final_energy_centers_efficiency], 
    certificate_type: Certificate.certificate_types[:energy_centers_efficiency_type], 
    renovation: false
  )

DevelopmentTypeScheme.find_or_create_by(
  scheme: provisional_energy_centers_efficiency_scheme, 
  development_type: provisional_energy_centers_efficiency_dt
)
DevelopmentTypeScheme.find_or_create_by(
  scheme: final_energy_centers_efficiency_scheme, 
  development_type: final_energy_centers_efficiency_dt
)

provisional_energy_centers_efficiency_category = 
  SchemeCategory.find_or_create_by(
    scheme: provisional_energy_centers_efficiency_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )
final_energy_centers_efficiency_category = 
  SchemeCategory.find_or_create_by(
    scheme: final_energy_centers_efficiency_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )

provisional_energy_centers_efficiency_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "	Checklist Specific", 
    number: 1, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: provisional_energy_centers_efficiency_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_energy_centers_efficiency_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_energy_centers_efficiency_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_energy_centers_efficiency_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

final_energy_centers_efficiency_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "	Checklist Specific", 
    number: 1, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: final_energy_centers_efficiency_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_energy_centers_efficiency_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_energy_centers_efficiency_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_energy_centers_efficiency_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

# ---------------------------- measurement_reporting_and_verification ----------------------------
provisional_measurement_reporting_and_verification_dt = 
  DevelopmentType.find_or_create_by!(
    display_weight: 9, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:provisional_measurement_reporting_and_verification], 
      certificate_type: Certificate.certificate_types[:measurement_reporting_and_verification_type], 
      assessment_stage: Certificate.assessment_stages[:measurement_reporting_and_verification_stage], 
      gsb_version: "2023"
    ), 
    mixable: false, 
    name: 'Typology'
  )
final_measurement_reporting_and_verification_dt = 
  DevelopmentType.find_or_create_by!(
    display_weight: 10, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:final_measurement_reporting_and_verification], 
      certificate_type: Certificate.certificate_types[:measurement_reporting_and_verification_type], 
      assessment_stage: Certificate.assessment_stages[:measurement_reporting_and_verification_stage], 
      gsb_version: "2023"
    ), 
    mixable: false, 
    name: 'Typology'
  )

provisional_measurement_reporting_and_verification_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:provisional_measurement_reporting_and_verification], 
    certificate_type: Certificate.certificate_types[:measurement_reporting_and_verification_type], 
    renovation: false
  )
final_measurement_reporting_and_verification_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:final_measurement_reporting_and_verification], 
    certificate_type: Certificate.certificate_types[:measurement_reporting_and_verification_type], 
    renovation: false
  )

DevelopmentTypeScheme.find_or_create_by(
  scheme: provisional_measurement_reporting_and_verification_scheme, 
  development_type: provisional_measurement_reporting_and_verification_dt
)
DevelopmentTypeScheme.find_or_create_by(
  scheme: final_measurement_reporting_and_verification_scheme, 
  development_type: final_measurement_reporting_and_verification_dt
)

provisional_measurement_reporting_and_verification_category = 
  SchemeCategory.find_or_create_by(
    scheme: provisional_measurement_reporting_and_verification_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )
final_measurement_reporting_and_verification_category = 
  SchemeCategory.find_or_create_by(
    scheme: final_measurement_reporting_and_verification_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )

provisional_measurement_reporting_and_verification_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "	Checklist Specific", 
    number: 1, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: provisional_measurement_reporting_and_verification_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_measurement_reporting_and_verification_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_measurement_reporting_and_verification_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_measurement_reporting_and_verification_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

final_measurement_reporting_and_verification_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "	Checklist Specific", 
    number: 1, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: final_measurement_reporting_and_verification_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_measurement_reporting_and_verification_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_measurement_reporting_and_verification_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_measurement_reporting_and_verification_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)


# ---------------------------- building_water_efficiency ----------------------------
provisional_building_water_efficiency_dt = 
  DevelopmentType.find_or_create_by!(
    display_weight: 11, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:provisional_building_water_efficiency], 
      certificate_type: Certificate.certificate_types[:building_water_efficiency_type], 
      assessment_stage: Certificate.assessment_stages[:building_water_efficiency_stage], 
      gsb_version: "2023"
    ), 
    mixable: false, 
    name: 'Typology'
  )
final_building_water_efficiency_dt = 
  DevelopmentType.find_or_create_by!(
    display_weight: 12, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:final_building_water_efficiency], 
      certificate_type: Certificate.certificate_types[:building_water_efficiency_type], 
      assessment_stage: Certificate.assessment_stages[:building_water_efficiency_stage], 
      gsb_version: "2023",
    ), 
    mixable: false, 
    name: 'Typology'
  )

provisional_building_water_efficiency_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:provisional_building_water_efficiency], 
    certificate_type: Certificate.certificate_types[:building_water_efficiency_type], 
    renovation: false
  )
final_building_water_efficiency_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:final_building_water_efficiency], 
    certificate_type: Certificate.certificate_types[:building_water_efficiency_type], 
    renovation: false
  )

DevelopmentTypeScheme.find_or_create_by(
  scheme: provisional_building_water_efficiency_scheme, 
  development_type: provisional_building_water_efficiency_dt
)
DevelopmentTypeScheme.find_or_create_by(
  scheme: final_building_water_efficiency_scheme, 
  development_type: final_building_water_efficiency_dt
)

provisional_building_water_efficiency_category = 
  SchemeCategory.find_or_create_by(
    scheme: provisional_building_water_efficiency_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )
final_building_water_efficiency_category = 
  SchemeCategory.find_or_create_by(
    scheme: final_building_water_efficiency_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )

provisional_building_water_efficiency_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "	Checklist Specific", 
    number: 1, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: provisional_building_water_efficiency_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_building_water_efficiency_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_building_water_efficiency_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_building_water_efficiency_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

final_building_water_efficiency_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "	Checklist Specific", 
    number: 1, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: final_building_water_efficiency_category
  )

SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_building_water_efficiency_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_building_water_efficiency_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_building_water_efficiency_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)


# ---------------------------- events_carbon_neutrality ----------------------------
provisional_events_carbon_neutrality_dt = 
  DevelopmentType.find_or_create_by!(
    display_weight: 13, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:provisional_events_carbon_neutrality], 
      certificate_type: Certificate.certificate_types[:events_carbon_neutrality_type], 
      assessment_stage: Certificate.assessment_stages[:events_carbon_neutrality_stage], 
      gsb_version: "2023"
    ), 
    mixable: false, 
    name: 'Typology'
  )
final_events_carbon_neutrality_dt = 
  DevelopmentType.find_or_create_by!(
    display_weight: 14, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:final_events_carbon_neutrality], 
      certificate_type: Certificate.certificate_types[:events_carbon_neutrality_type], 
      assessment_stage: Certificate.assessment_stages[:events_carbon_neutrality_stage], 
      gsb_version: "2023"
    ), 
    mixable: false, 
    name: 'Typology'
  )

provisional_events_carbon_neutrality_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:provisional_events_carbon_neutrality], 
    certificate_type: Certificate.certificate_types[:events_carbon_neutrality_type], 
    renovation: false
  )
final_events_carbon_neutrality_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:final_events_carbon_neutrality], 
    certificate_type: Certificate.certificate_types[:events_carbon_neutrality_type], 
    renovation: false
  )

DevelopmentTypeScheme.find_or_create_by(
  scheme: provisional_events_carbon_neutrality_scheme, 
  development_type: provisional_events_carbon_neutrality_dt
)
DevelopmentTypeScheme.find_or_create_by(
  scheme: final_events_carbon_neutrality_scheme, 
  development_type: final_events_carbon_neutrality_dt
)

provisional_events_carbon_neutrality_category = 
  SchemeCategory.find_or_create_by(
    scheme: provisional_events_carbon_neutrality_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )
final_events_carbon_neutrality_category = 
  SchemeCategory.find_or_create_by(
    scheme: final_events_carbon_neutrality_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )

provisional_events_carbon_neutrality_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "	Checklist Specific", 
    number: 1, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: provisional_events_carbon_neutrality_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_events_carbon_neutrality_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_events_carbon_neutrality_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_events_carbon_neutrality_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

final_events_carbon_neutrality_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "	Checklist Specific", 
    number: 1, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: final_events_carbon_neutrality_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_events_carbon_neutrality_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_events_carbon_neutrality_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_events_carbon_neutrality_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

# ---------------------------- products_ecolabeling ----------------------------
provisional_products_ecolabeling_dt = 
  DevelopmentType.find_or_create_by!(
    display_weight: 15, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:provisional_products_ecolabeling], 
      certificate_type: Certificate.certificate_types[:products_ecolabeling_type], 
      assessment_stage: Certificate.assessment_stages[:products_ecolabeling_stage], 
      gsb_version: "2023"
    ), 
    mixable: false, 
    name: 'Typology'
  )
final_products_ecolabeling_dt = 
  DevelopmentType.find_or_create_by!(
    display_weight: 16, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:final_products_ecolabeling], 
      certificate_type: Certificate.certificate_types[:products_ecolabeling_type], 
      assessment_stage: Certificate.assessment_stages[:products_ecolabeling_stage], 
      gsb_version: "2023"
    ), 
    mixable: false, 
    name: 'Typology'
  )

provisional_products_ecolabeling_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:provisional_products_ecolabeling], 
    certificate_type: Certificate.certificate_types[:products_ecolabeling_type], 
    renovation: false
  )
final_products_ecolabeling_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:final_products_ecolabeling], 
    certificate_type: Certificate.certificate_types[:products_ecolabeling_type], 
    renovation: false
  )

DevelopmentTypeScheme.find_or_create_by(
    scheme: provisional_products_ecolabeling_scheme, 
    development_type: provisional_products_ecolabeling_dt
  )
DevelopmentTypeScheme.find_or_create_by(
    scheme: final_products_ecolabeling_scheme, 
    development_type: final_products_ecolabeling_dt
  )

provisional_products_ecolabeling_category = 
  SchemeCategory.find_or_create_by(
    scheme: provisional_products_ecolabeling_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )
final_products_ecolabeling_category = 
  SchemeCategory.find_or_create_by(
    scheme: final_products_ecolabeling_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )

provisional_products_ecolabeling_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "	Checklist Specific", 
    number: 1, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: provisional_products_ecolabeling_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_products_ecolabeling_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_products_ecolabeling_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_products_ecolabeling_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

final_products_ecolabeling_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "	Checklist Specific", 
    number: 1, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: final_products_ecolabeling_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_products_ecolabeling_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_products_ecolabeling_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_products_ecolabeling_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)


# ---------------------------- Green IT ----------------------------
provisional_green_IT_dt = 
  DevelopmentType.find_or_create_by!(
    display_weight: 17, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:provisional_green_IT], 
      certificate_type: Certificate.certificate_types[:green_IT_type], 
      assessment_stage: Certificate.assessment_stages[:green_IT_stage], 
      gsb_version: "2023"
    ), 
    mixable: false, 
    name: 'Typology'
  )
final_green_IT_dt = 
  DevelopmentType.find_or_create_by!(
    display_weight: 18, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:final_green_IT], 
      certificate_type: Certificate.certificate_types[:green_IT_type], 
      assessment_stage: Certificate.assessment_stages[:green_IT_stage], 
      gsb_version: "2023"
    ), 
    mixable: false, 
    name: 'Typology'
  )

provisional_green_IT_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:provisional_green_IT], 
    certificate_type: Certificate.certificate_types[:green_IT_type], 
    renovation: false
  )
final_green_IT_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:final_green_IT], 
    certificate_type: Certificate.certificate_types[:green_IT_type], 
    renovation: false
  )

DevelopmentTypeScheme.find_or_create_by(
    scheme: provisional_green_IT_scheme, 
    development_type: provisional_green_IT_dt
  )
DevelopmentTypeScheme.find_or_create_by(
    scheme: final_green_IT_scheme, 
    development_type: final_green_IT_dt
  )

provisional_green_IT_category = 
  SchemeCategory.find_or_create_by(
    scheme: provisional_green_IT_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )
final_green_IT_category = 
  SchemeCategory.find_or_create_by(
    scheme: final_green_IT_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )

provisional_green_IT_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "	Checklist Specific", 
    number: 1, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: provisional_green_IT_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_green_IT_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_green_IT_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_green_IT_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

final_green_IT_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "	Checklist Specific", 
    number: 1, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: final_green_IT_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_green_IT_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_green_IT_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_green_IT_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)


# ---------------------------- Net-Zero Energy ----------------------------
provisional_net_zero_energy_dt = 
  DevelopmentType.find_or_create_by!(
    display_weight: 19, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:provisional_net_zero_energy], 
      certificate_type: Certificate.certificate_types[:net_zero_energy_type], 
      assessment_stage: Certificate.assessment_stages[:net_zero_energy_stage], 
      gsb_version: "2023"
    ), 
    mixable: false, 
    name: 'Typology'
  )
final_net_zero_energy_dt = 
  DevelopmentType.find_or_create_by!(
    display_weight: 20, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:final_net_zero_energy], 
      certificate_type: Certificate.certificate_types[:net_zero_energy_type], 
      assessment_stage: Certificate.assessment_stages[:net_zero_energy_stage], 
      gsb_version: "2023"
    ), 
    mixable: false, 
    name: 'Typology'
  )

provisional_net_zero_energy_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:provisional_net_zero_energy], 
    certificate_type: Certificate.certificate_types[:net_zero_energy_type], 
    renovation: false
  )
final_net_zero_energy_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:final_net_zero_energy], 
    certificate_type: Certificate.certificate_types[:net_zero_energy_type], 
    renovation: false
  )

DevelopmentTypeScheme.find_or_create_by(
    scheme: provisional_net_zero_energy_scheme, 
    development_type: provisional_net_zero_energy_dt
  )
DevelopmentTypeScheme.find_or_create_by(
    scheme: final_net_zero_energy_scheme, 
    development_type: final_net_zero_energy_dt
  )

provisional_net_zero_energy_category = 
  SchemeCategory.find_or_create_by(
    scheme: provisional_net_zero_energy_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )
final_net_zero_energy_category = 
  SchemeCategory.find_or_create_by(
    scheme: final_net_zero_energy_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )

provisional_net_zero_energy_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "	Checklist Specific", 
    number: 1, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: provisional_net_zero_energy_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_net_zero_energy_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_net_zero_energy_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_net_zero_energy_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

final_net_zero_energy_criterion = 
  SchemeCriterion.find_or_create_by(
    name: "	Checklist Specific", 
    number: 1, 
    scores_a: YAML.load("[[1, 1.0]]\n"), 
    minimum_score_a: 0, 
    maximum_score_a: 1, 
    minimum_valid_score_a: 0, 
    weight_a: 1, 
    is_checklist: true, 
    shared: false, 
    scheme_category: final_net_zero_energy_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_net_zero_energy_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_net_zero_energy_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_net_zero_energy_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

puts "Development Types, Schemes, Scheme Category & Scheme Criteria are added successfully.........."
