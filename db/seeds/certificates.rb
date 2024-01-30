Certificate.find_or_create_by(
  name: 'Stage 1: Provisional Certificate', 
  certification_type: Certificate.certification_types[:provisional_energy_centers_efficiency], 
  certificate_type: Certificate.certificate_types[:energy_centers_efficiency_type], 
  assessment_stage: Certificate.assessment_stages[:energy_centers_efficiency_stage], 
  gsb_version: "2023", 
  display_weight: 1
)
Certificate.find_or_create_by(
  name: 'Stage 2: Final Certificate', 
  certification_type: Certificate.certification_types[:final_energy_centers_efficiency], 
  certificate_type: Certificate.certificate_types[:energy_centers_efficiency_type], 
  assessment_stage: Certificate.assessment_stages[:energy_centers_efficiency_stage], 
  gsb_version: "2023", 
  display_weight: 2
)

Certificate.find_or_create_by(
  name: 'Stage 1: Provisional Certificate', 
  certification_type: Certificate.certification_types[:provisional_building_energy_efficiency], 
  certificate_type: Certificate.certificate_types[:building_energy_efficiency_type], 
  assessment_stage: Certificate.assessment_stages[:building_energy_efficiency_stage], 
  gsb_version: "2023", 
  display_weight: 3
)
Certificate.find_or_create_by(
  name: 'Stage 2: Final Certificate', 
  certification_type: Certificate.certification_types[:final_building_energy_efficiency], 
  certificate_type: Certificate.certificate_types[:building_energy_efficiency_type], 
  assessment_stage: Certificate.assessment_stages[:building_energy_efficiency_stage], 
  gsb_version: "2023", 
  display_weight: 4
)

Certificate.find_or_create_by(
  name: 'Stage 1: Provisional Certificate', 
  certification_type: Certificate.certification_types[:provisional_healthy_buildings], 
  certificate_type: Certificate.certificate_types[:healthy_buildings_type], 
  assessment_stage: Certificate.assessment_stages[:healthy_buildings_stage], 
  gsb_version: "2023", 
  display_weight: 5
)
Certificate.find_or_create_by(
  name: 'Stage 2: Final Certificate', 
  certification_type: Certificate.certification_types[:final_Healthy_buildings], 
  certificate_type: Certificate.certificate_types[:healthy_buildings_type], 
  assessment_stage: Certificate.assessment_stages[:healthy_buildings_stage], 
  gsb_version: "2023", 
  display_weight: 6
)

Certificate.find_or_create_by(
  name: 'Stage 1: Provisional Certificate', 
  certification_type: Certificate.certification_types[:provisional_indoor_air_quality], 
  certificate_type: Certificate.certificate_types[:indoor_air_quality_type], 
  assessment_stage: Certificate.assessment_stages[:indoor_air_quality_stage], 
  gsb_version: "2023", 
  display_weight: 7
)
Certificate.find_or_create_by(
  name: 'Stage 2: Final Certificate', 
  certification_type: Certificate.certification_types[:final_indoor_air_quality], 
  certificate_type: Certificate.certificate_types[:indoor_air_quality_type], 
  assessment_stage: Certificate.assessment_stages[:indoor_air_quality_stage], 
  gsb_version: "2023", 
  display_weight: 8
)

Certificate.find_or_create_by(
  name: 'Stage 1: Provisional Certificate', 
  certification_type: Certificate.certification_types[:provisional_measurement_reporting_and_Verification], 
  certificate_type: Certificate.certificate_types[:measurement_reporting_and_Verification_type], 
  assessment_stage: Certificate.assessment_stages[:measurement_reporting_and_Verification_stage], 
  gsb_version: "2023", 
  display_weight: 9
)
Certificate.find_or_create_by(
  name: 'Stage 2: Final Certificate', 
  certification_type: Certificate.certification_types[:final_measurement_reporting_and_Verification], 
  certificate_type: Certificate.certificate_types[:measurement_reporting_and_Verification_type], 
  assessment_stage: Certificate.assessment_stages[:measurement_reporting_and_Verification_stage], 
  gsb_version: "2023", 
  display_weight: 10
)

Certificate.find_or_create_by(
  name: 'Stage 1: Provisional Certificate', 
  certification_type: Certificate.certification_types[:provisional_building_water_efficiency], 
  certificate_type: Certificate.certificate_types[:building_water_efficiency_type], 
  assessment_stage: Certificate.assessment_stages[:building_water_efficiency_stage], 
  gsb_version: "2023", 
  display_weight: 11
)
Certificate.find_or_create_by(
  name: 'Stage 2: Final Certificate', 
  certification_type: Certificate.certification_types[:final_building_water_efficiency], 
  certificate_type: Certificate.certificate_types[:building_water_efficiency_type], 
  assessment_stage: Certificate.assessment_stages[:building_water_efficiency_stage], 
  gsb_version: "2023", 
  display_weight: 12
)

Certificate.find_or_create_by(
  name: 'Stage 1: Provisional Certificate', 
  certification_type: Certificate.certification_types[:provisional_events_carbon_neutrality], 
  certificate_type: Certificate.certificate_types[:events_carbon_neutrality_type], 
  assessment_stage: Certificate.assessment_stages[:events_carbon_neutrality_stage], 
  gsb_version: "2023", 
  display_weight: 13
)
Certificate.find_or_create_by(
  name: 'Stage 2: Final Certificate', 
  certification_type: Certificate.certification_types[:final_events_carbon_neutrality], 
  certificate_type: Certificate.certificate_types[:events_carbon_neutrality_type], 
  assessment_stage: Certificate.assessment_stages[:events_carbon_neutrality_stage], 
  gsb_version: "2023", 
  display_weight: 14
)

Certificate.find_or_create_by(
  name: 'Stage 1: Provisional Certificate', 
  certification_type: Certificate.certification_types[:provisional_products_ecolabeling], 
  certificate_type: Certificate.certificate_types[:products_ecolabeling_type], 
  assessment_stage: Certificate.assessment_stages[:products_ecolabeling_stage], 
  gsb_version: "2023", 
  display_weight: 15
)
Certificate.find_or_create_by(
  name: 'Stage 2: Final Certificate', 
  certification_type: Certificate.certification_types[:final_products_ecolabeling], 
  certificate_type: Certificate.certificate_types[:products_ecolabeling_type], 
  assessment_stage: Certificate.assessment_stages[:products_ecolabeling_stage], 
  gsb_version: "2023", 
  display_weight: 16
)

puts "Certificates are added successfully.........."
