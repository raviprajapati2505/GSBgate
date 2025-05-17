Certificate.find_or_create_by!(
  name: 'Stage 1: Provisional Certificate', 
  certification_type: Certificate.certification_types[:provisional_energy_centers_efficiency], 
  certificate_type: Certificate.certificate_types[:energy_centers_efficiency_type], 
  assessment_stage: Certificate.assessment_stages[:energy_centers_efficiency_stage], 
  gsb_version: "2023", 
  display_weight: 1
)
Certificate.find_or_create_by!(
  name: 'Stage 2: Final Certificate', 
  certification_type: Certificate.certification_types[:final_energy_centers_efficiency], 
  certificate_type: Certificate.certificate_types[:energy_centers_efficiency_type], 
  assessment_stage: Certificate.assessment_stages[:energy_centers_efficiency_stage], 
  gsb_version: "2023", 
  display_weight: 2
)

Certificate.find_or_create_by!(
  name: 'Stage 1: Provisional Certificate', 
  certification_type: Certificate.certification_types[:provisional_measurement_reporting_and_verification], 
  certificate_type: Certificate.certificate_types[:measurement_reporting_and_verification_type], 
  assessment_stage: Certificate.assessment_stages[:measurement_reporting_and_verification_stage], 
  gsb_version: "2023", 
  display_weight: 9
)
Certificate.find_or_create_by!(
  name: 'Stage 2: Final Certificate', 
  certification_type: Certificate.certification_types[:final_measurement_reporting_and_verification], 
  certificate_type: Certificate.certificate_types[:measurement_reporting_and_verification_type], 
  assessment_stage: Certificate.assessment_stages[:measurement_reporting_and_verification_stage], 
  gsb_version: "2023", 
  display_weight: 10
)

Certificate.find_or_create_by!(
  name: 'Stage 1: Provisional Certificate', 
  certification_type: Certificate.certification_types[:provisional_building_water_efficiency], 
  certificate_type: Certificate.certificate_types[:building_water_efficiency_type], 
  assessment_stage: Certificate.assessment_stages[:building_water_efficiency_stage], 
  gsb_version: "2023", 
  display_weight: 11
)
Certificate.find_or_create_by!(
  name: 'Stage 2: Final Certificate', 
  certification_type: Certificate.certification_types[:final_building_water_efficiency], 
  certificate_type: Certificate.certificate_types[:building_water_efficiency_type], 
  assessment_stage: Certificate.assessment_stages[:building_water_efficiency_stage], 
  gsb_version: "2023", 
  display_weight: 12
)

Certificate.find_or_create_by!(
  name: 'Stage 1: Provisional Certificate', 
  certification_type: Certificate.certification_types[:provisional_events_carbon_neutrality], 
  certificate_type: Certificate.certificate_types[:events_carbon_neutrality_type], 
  assessment_stage: Certificate.assessment_stages[:events_carbon_neutrality_stage], 
  gsb_version: "2023", 
  display_weight: 13
)
Certificate.find_or_create_by!(
  name: 'Stage 2: Final Certificate', 
  certification_type: Certificate.certification_types[:final_events_carbon_neutrality], 
  certificate_type: Certificate.certificate_types[:events_carbon_neutrality_type], 
  assessment_stage: Certificate.assessment_stages[:events_carbon_neutrality_stage], 
  gsb_version: "2023", 
  display_weight: 14
)

Certificate.find_or_create_by!(
  name: 'Stage 1: Provisional Certificate', 
  certification_type: Certificate.certification_types[:provisional_products_ecolabeling], 
  certificate_type: Certificate.certificate_types[:products_ecolabeling_type], 
  assessment_stage: Certificate.assessment_stages[:products_ecolabeling_stage], 
  gsb_version: "2023", 
  display_weight: 15
)
Certificate.find_or_create_by!(
  name: 'Stage 2: Final Certificate', 
  certification_type: Certificate.certification_types[:final_products_ecolabeling], 
  certificate_type: Certificate.certificate_types[:products_ecolabeling_type], 
  assessment_stage: Certificate.assessment_stages[:products_ecolabeling_stage], 
  gsb_version: "2023", 
  display_weight: 16
)

Certificate.find_or_create_by!(
  name: 'Stage 1: Provisional Certificate', 
  certification_type: Certificate.certification_types[:provisional_green_IT], 
  certificate_type: Certificate.certificate_types[:green_IT_type], 
  assessment_stage: Certificate.assessment_stages[:green_IT_stage], 
  gsb_version: "2023", 
  display_weight: 17
)
Certificate.find_or_create_by!(
  name: 'Stage 2: Final Certificate', 
  certification_type: Certificate.certification_types[:final_green_IT], 
  certificate_type: Certificate.certificate_types[:green_IT_type], 
  assessment_stage: Certificate.assessment_stages[:green_IT_stage], 
  gsb_version: "2023", 
  display_weight: 18
)

Certificate.find_or_create_by!(
  name: 'Stage 1: Provisional Certificate', 
  certification_type: Certificate.certification_types[:provisional_energy_building], 
  certificate_type: Certificate.certificate_types[:energy_building_type], 
  assessment_stage: Certificate.assessment_stages[:energy_building_stage], 
  gsb_version: "2023", 
  display_weight: 19
)
Certificate.find_or_create_by!(
  name: 'Stage 2: Final Certificate', 
  certification_type: Certificate.certification_types[:final_energy_building], 
  certificate_type: Certificate.certificate_types[:energy_building_type], 
  assessment_stage: Certificate.assessment_stages[:energy_building_stage], 
  gsb_version: "2023", 
  display_weight: 20
)

puts "Certificates are added successfully.........."
