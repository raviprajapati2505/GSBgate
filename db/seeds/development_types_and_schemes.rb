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


# ---------------------------- building_energy_efficiency ----------------------------
provisional_building_energy_efficiency_dt = 
  DevelopmentType.find_or_create_by!(
    display_weight: 3, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:provisional_building_energy_efficiency], 
      certificate_type: Certificate.certificate_types[:building_energy_efficiency_type], 
      assessment_stage: Certificate.assessment_stages[:building_energy_efficiency_stage], 
      gsb_version: "2023"
    ), 
    mixable: false, 
    name: 'Typology'
  )
final_building_energy_efficiency_dt =
  DevelopmentType.find_or_create_by!(
    display_weight: 4, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:final_building_energy_efficiency], 
      certificate_type: Certificate.certificate_types[:building_energy_efficiency_type], 
      assessment_stage: Certificate.assessment_stages[:building_energy_efficiency_stage], 
      gsb_version: "2023"
    ), 
    mixable: false, 
    name: 'Typology'
  )

provisional_building_energy_efficiency_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:provisional_building_energy_efficiency], 
    certificate_type: Certificate.certificate_types[:building_energy_efficiency_type], 
    renovation: false
  )
final_building_energy_efficiency_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:final_building_energy_efficiency], 
    certificate_type: Certificate.certificate_types[:building_energy_efficiency_type], 
    renovation: false
  )

DevelopmentTypeScheme.find_or_create_by(
  scheme: provisional_building_energy_efficiency_scheme, 
  development_type: provisional_building_energy_efficiency_dt
)
DevelopmentTypeScheme.find_or_create_by(
  scheme: final_building_energy_efficiency_scheme, 
  development_type: final_building_energy_efficiency_dt
)

provisional_building_energy_efficiency_category = 
  SchemeCategory.find_or_create_by(
    scheme: provisional_building_energy_efficiency_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )
final_building_energy_efficiency_category = 
  SchemeCategory.find_or_create_by(
    scheme: final_building_energy_efficiency_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )

provisional_building_energy_efficiency_criterion = 
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
    scheme_category: provisional_building_energy_efficiency_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_building_energy_efficiency_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_building_energy_efficiency_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_building_energy_efficiency_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

final_building_energy_efficiency_criterion = 
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
    scheme_category: final_building_energy_efficiency_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_building_energy_efficiency_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_building_energy_efficiency_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_building_energy_efficiency_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)


# ---------------------------- healthy_buildings ----------------------------
provisional_healthy_buildings_dt = 
  DevelopmentType.find_or_create_by!(
    display_weight: 5, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:provisional_healthy_buildings], 
      certificate_type: Certificate.certificate_types[:healthy_buildings_type], 
      assessment_stage: Certificate.assessment_stages[:healthy_buildings_stage], 
      gsb_version: "2023"
    ), 
    mixable: false, 
    name: 'Typology'
  )
final_Healthy_buildings_dt = 
  DevelopmentType.find_or_create_by!(
    display_weight: 6, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:final_Healthy_buildings], 
      certificate_type: Certificate.certificate_types[:healthy_buildings_type], 
      assessment_stage: Certificate.assessment_stages[:healthy_buildings_stage], 
      gsb_version: "2023"
    ), 
    mixable: false, 
    name: 'Typology'
  )

provisional_healthy_buildings_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:provisional_healthy_buildings], 
    certificate_type: Certificate.certificate_types[:healthy_buildings_type], 
    renovation: false
  )
final_healthy_buildings_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:final_healthy_buildings], 
    certificate_type: Certificate.certificate_types[:healthy_buildings_type], 
    renovation: false
  )

DevelopmentTypeScheme.find_or_create_by(
  scheme: provisional_healthy_buildings_scheme, 
  development_type: provisional_healthy_buildings_dt
)
DevelopmentTypeScheme.find_or_create_by(
  scheme: final_healthy_buildings_scheme, 
  development_type: final_Healthy_buildings_dt
)

provisional_healthy_buildings_category = 
  SchemeCategory.find_or_create_by(
    scheme: provisional_healthy_buildings_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )
final_healthy_buildings_category = 
  SchemeCategory.find_or_create_by(
    scheme: final_healthy_buildings_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )

provisional_healthy_buildings_criterion = 
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
    scheme_category: provisional_healthy_buildings_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_healthy_buildings_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_healthy_buildings_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_healthy_buildings_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

final_healthy_buildings_criterion = 
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
    scheme_category: final_healthy_buildings_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_healthy_buildings_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_healthy_buildings_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_healthy_buildings_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)


# ---------------------------- indoor_air_quality ----------------------------
provisional_indoor_air_quality_dt = 
  DevelopmentType.find_or_create_by!(
    display_weight: 7, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:provisional_indoor_air_quality], 
      certificate_type: Certificate.certificate_types[:indoor_air_quality_type], 
      assessment_stage: Certificate.assessment_stages[:indoor_air_quality_stage], 
      gsb_version: "2023"
    ), 
    mixable: false, 
    name: 'Typology'
  )
final_indoor_air_quality_dt = 
  DevelopmentType.find_or_create_by!(
    display_weight: 8, 
    certificate: Certificate.find_by(
      certification_type: Certificate.certification_types[:final_indoor_air_quality], 
      certificate_type: Certificate.certificate_types[:indoor_air_quality_type], 
      assessment_stage: Certificate.assessment_stages[:indoor_air_quality_stage], 
      gsb_version: "2023"
    ), 
    mixable: false, 
    name: 'Typology'
  )

provisional_indoor_air_quality_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:provisional_indoor_air_quality], 
    certificate_type: Certificate.certificate_types[:indoor_air_quality_type], 
    renovation: false
  )
final_indoor_air_quality_scheme = 
  Scheme.find_or_create_by(
    name: "Typology", 
    certification_type: Certificate.certification_types[:final_indoor_air_quality], 
    certificate_type: Certificate.certificate_types[:indoor_air_quality_type], 
    renovation: false
  )

DevelopmentTypeScheme.find_or_create_by(
  scheme: provisional_indoor_air_quality_scheme, 
  development_type: provisional_indoor_air_quality_dt
)
DevelopmentTypeScheme.find_or_create_by(
  scheme: final_indoor_air_quality_scheme, 
  development_type: final_indoor_air_quality_dt
)

provisional_indoor_air_quality_category = 
  SchemeCategory.find_or_create_by(
    scheme: provisional_indoor_air_quality_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )
final_indoor_air_quality_category = 
  SchemeCategory.find_or_create_by(
    scheme: final_indoor_air_quality_scheme, 
    code: "G", 
    name: "Generic", 
    impacts: "", 
    mitigate_impact: "", 
    shared: false, 
    display_weight: 1, 
    is_checklist: true
  )

provisional_indoor_air_quality_criterion = 
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
    scheme_category: provisional_indoor_air_quality_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_indoor_air_quality_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_indoor_air_quality_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: provisional_indoor_air_quality_criterion, 
  label: 'Achieved Checklist Status', 
  display_weight: 3
)

final_indoor_air_quality_criterion = 
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
    scheme_category: final_indoor_air_quality_category
  )
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_indoor_air_quality_criterion, 
  label: 'Targeted Checklist Status', 
  display_weight: 1
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_indoor_air_quality_criterion, 
  label: 'Submitted Checklist Status', 
  display_weight: 2
)
SchemeCriterionBox.find_or_create_by(
  scheme_criterion: final_indoor_air_quality_criterion, 
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

puts "Development Types, Schemes, Scheme Category & Scheme Criteria are added successfully.........."
