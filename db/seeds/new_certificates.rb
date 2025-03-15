# ---------------------------- Certificates ----------------------------
certificates = [
  { name: 'Energy Label for Building Performance', type: :energy_label_for_building_performance },
  { name: 'Indoor Air Quality (IAQ) Certification', type: :indoor_air_quality_certification },
  { name: 'Indoor Environmental Quality (IEQ) Certification', type: :indoor_air_quality_certification },
  { name: 'Energy Label for Wastewater Treatment Plant (WTP)', type: :energy_label_for_wastewater_treatment_plant },
  { name: 'Energy Label for Leachate Treatment Plant (LTP)', type: :energy_label_for_leachate_treatment_plant },
  { name: 'Healthy Building Label', type: :healthy_building_label },
  { name: 'Energy label for Industrial application', type: :energy_label_for_industrial_application },
  { name: 'Energy label for Infrastructure projects', type: :energy_label_for_infrastructure_projects }
]

certificates.each_with_index do |certificate, index|
  Certificate.find_or_create_by!(
    name: "Stage 1: Provisional Certificate",
    certification_type: Certificate.certification_types[:"provisional_#{certificate[:type]}"],
    certificate_type: Certificate.certificate_types[:"#{certificate[:type]}_type"],
    assessment_stage: Certificate.assessment_stages[:"#{certificate[:type]}_stage"],
    gsb_version: "2023",
    display_weight: (index + 12) * 2 - 1
  )
  Certificate.find_or_create_by!(
    name: "Stage 2: Final Certificate",
    certification_type: Certificate.certification_types[:"final_#{certificate[:type]}"],
    certificate_type: Certificate.certificate_types[:"#{certificate[:type]}_type"],
    assessment_stage: Certificate.assessment_stages[:"#{certificate[:type]}_stage"],
    gsb_version: "2023",
    display_weight: (index + 12) * 2
  )
end

#==========================================Development Types and Schemes======================================================
def create_certification_data(type_key,number)
  provisional_certificate = Certificate.find_by(
    certification_type: Certificate.certification_types[:"provisional_#{type_key}"],
    certificate_type: Certificate.certificate_types[:"#{type_key}_type"],
    assessment_stage: Certificate.assessment_stages[:"#{type_key}_stage"],
    gsb_version: "2023"
  )
  
  final_certificate = Certificate.find_by(
    certification_type: Certificate.certification_types[:"final_#{type_key}"],
    certificate_type: Certificate.certificate_types[:"#{type_key}_type"],
    assessment_stage: Certificate.assessment_stages[:"#{type_key}_stage"],
    gsb_version: "2023"
  )

  provisional_dt = DevelopmentType.find_or_create_by!(
    display_weight: number+1,
    certificate: provisional_certificate,
    mixable: false,
    name: 'Typology'
  )

  final_dt = DevelopmentType.find_or_create_by!(
    display_weight: number+2,
    certificate: final_certificate,
    mixable: false,
    name: 'Typology'
  )

  provisional_scheme = Scheme.find_or_create_by!(
    name: "Typology",
    certification_type: Certificate.certification_types[:"provisional_#{type_key}"],
    certificate_type: Certificate.certificate_types[:"#{type_key}_type"],
    renovation: false
  )

  final_scheme = Scheme.find_or_create_by!(
    name: "Typology",
    certification_type: Certificate.certification_types[:"final_#{type_key}"],
    certificate_type: Certificate.certificate_types[:"#{type_key}_type"],
    renovation: false
  )

  DevelopmentTypeScheme.find_or_create_by!(
    scheme: provisional_scheme,
    development_type: provisional_dt
  )

  DevelopmentTypeScheme.find_or_create_by!(
    scheme: final_scheme,
    development_type: final_dt
  )

  provisional_category = SchemeCategory.find_or_create_by!(
    scheme: provisional_scheme,
    code: "G",
    name: "Generic",
    impacts: "",
    mitigate_impact: "",
    shared: false,
    display_weight: 1,
    is_checklist: true
  )

  final_category = SchemeCategory.find_or_create_by!(
    scheme: final_scheme,
    code: "G",
    name: "Generic",
    impacts: "",
    mitigate_impact: "",
    shared: false,
    display_weight: 1,
    is_checklist: true
  )

  checklist_scores = YAML.load("[[1, 1.0]]\n")

  provisional_criterion = SchemeCriterion.find_or_create_by!(
    name: "Checklist Specific",
    number: 1,
    scores_a: checklist_scores,
    minimum_score_a: 0,
    maximum_score_a: 1,
    minimum_valid_score_a: 0,
    weight_a: 1,
    is_checklist: true,
    shared: false,
    scheme_category: provisional_category
  )

  final_criterion = SchemeCriterion.find_or_create_by!(
    name: "Checklist Specific",
    number: 1,
    scores_a: checklist_scores,
    minimum_score_a: 0,
    maximum_score_a: 1,
    minimum_valid_score_a: 0,
    weight_a: 1,
    is_checklist: true,
    shared: false,
    scheme_category: final_category
  )

  %w[Targeted Submitted Achieved].each_with_index do |label, index|
    SchemeCriterionBox.find_or_create_by!(
      scheme_criterion: provisional_criterion,
      label: "#{label} Checklist Status",
      display_weight: index + 1
    )

    SchemeCriterionBox.find_or_create_by!(
      scheme_criterion: final_criterion,
      label: "#{label} Checklist Status",
      display_weight: index + 1
    )
  end
end

# **Call this function with the desired type**
create_certification_data(:energy_label_for_building_performance,22)
create_certification_data(:indoor_air_quality_certification,24)
create_certification_data(:indoor_environmental_quality_certification,26)
create_certification_data(:energy_label_for_wastewater_treatment_plant,28)
create_certification_data(:energy_label_for_leachate_treatment_plant,30)
create_certification_data(:healthy_building_label,32)
create_certification_data(:energy_label_for_industrial_application,34)
create_certification_data(:energy_label_for_infrastructure_projects,36)


#==========================================Licences======================================================
# Define certificate types with their display names as provided in YAML
certificate_types = {
  energy_label_for_building_performance_type: "Energy Label for Building Performance",
  indoor_air_quality_certification_type: "Indoor Air Quality (IAQ) Certification",
  indoor_environmental_quality_certification_type: "Indoor Environmental Quality (IEQ) Certification",
  energy_label_for_wastewater_treatment_plant_type: "Energy Label for Wastewater Treatment Plant (WTP)",
  energy_label_for_leachate_treatment_plant_type: "Energy Label for Leachate Treatment Plant (LTP)",
  healthy_building_label_type: "Healthy Building Label",
  energy_label_for_industrial_application_type: "Energy label for Industrial application",
  energy_label_for_infrastructure_projects_type: "Energy label for Infrastructure projects"
}

certificate_types.keys.each_with_index do |type_key, index|
  Licence.find_or_create_by!(
    licence_type: 'ServiceProviderLicence',
    display_name: "Service Provider - #{certificate_types[type_key]}",
    display_weight: 34 + index,  # Start from 34 dynamically
    title: "Service Provider - #{certificate_types[type_key]}",
    description: "#{certificate_types[type_key]} Service Provider", 
    certificate_type: Certificate.certificate_types[type_key],
    schemes: ['Typology'],
    applicability: Licence.applicabilities[:check_list]
  )
end

certificate_types.each_with_index do |(type_key, display_name), index|
  Licence.find_or_create_by!(
    licence_type: 'CgpLicence',
    display_name: "CGP - #{display_name}",
    display_weight: 42 + index,  # Start from 42 dynamically
    title: "CGP - #{display_name}",
    description: "#{display_name} Certified Green Professional",
    certificate_type: Certificate.certificate_types[type_key],
    applicability: Licence.applicabilities[:check_list]
  )
end

certificate_types.each_with_index do |(type_key, display_name), index|
  Licence.find_or_create_by!(
    licence_type: 'CepLicence',
    display_name: "CEP - #{display_name}",
    display_weight: 50 + index,  # Start from 50 dynamically
    title: "CEP - #{display_name}",
    description: "#{display_name} Certified Energy Professional",
    certificate_type: Certificate.certificate_types[type_key],
    applicability: Licence.applicabilities[:check_list]
  )
end