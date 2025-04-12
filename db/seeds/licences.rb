# ----------------------------------------- Licences for Corporates -----------------------------------------
# Energy Centers Efficiency
Licence.find_or_create_by!(
  licence_type: 'CorporateLicence',
  display_name: 'Corporate - Energy Centers Efficiency',
  display_weight: 1,
  title: 'Corporate - Energy Centers Efficiency',
  description: 'Energy Centers Efficiency Corporate',
  certificate_type: Certificate.certificate_types[:energy_centers_efficiency_type],
  schemes: ['Typology'],
  applicability: Licence.applicabilities[:check_list]
  
)

# Building Energy Efficiency
Licence.find_or_create_by!(
  licence_type: 'CorporateLicence',
  display_name: 'Corporate - Building Energy Efficiency',
  display_weight: 2,
  title: 'Corporate - Building Energy Efficiency',
  description: 'Building Energy Efficiency Corporate',
  certificate_type: Certificate.certificate_types[:building_energy_efficiency_type],
  schemes: ['Typology'],
  applicability: Licence.applicabilities[:check_list]
)

# Healthy Buildings
Licence.find_or_create_by!(
  licence_type: 'CorporateLicence',
  display_name: 'Corporate - Healthy Buildings',
  display_weight: 3,
  title: 'Corporate - Healthy Buildings',
  description: 'Healthy Buildings Corporate',
  certificate_type: Certificate.certificate_types[:healthy_buildings_type],
  schemes: ['Typology'],
  applicability: Licence.applicabilities[:check_list]
)

# Indoor Air Quality
Licence.find_or_create_by!(
  licence_type: 'CorporateLicence',
  display_name: 'Corporate - Indoor Air Quality',
  display_weight: 4,
  title: 'Corporate - Indoor Air Quality',
  description: 'Indoor Air Quality Corporate',
  certificate_type: Certificate.certificate_types[:indoor_air_quality_type],
  schemes: ['Typology'],
  applicability: Licence.applicabilities[:check_list]
)

# Measurement, Reporting And Verification (MRV)
Licence.find_or_create_by!(
  licence_type: 'CorporateLicence',
  display_name: 'Corporate - Measurement, Reporting And Verification (MRV)',
  display_weight: 5,
  title: 'Corporate - Measurement, Reporting And Verification (MRV)',
  description: 'Measurement, Reporting And Verification (MRV) Corporate',
  certificate_type: Certificate.certificate_types[:measurement_reporting_and_verification_type],
  schemes: ['Typology'],
  applicability: Licence.applicabilities[:check_list]
)

# Buildings Water Efficiency
Licence.find_or_create_by!(
  licence_type: 'CorporateLicence',
  display_name: 'Corporate - Buildings Water Efficiency',
  display_weight: 6,
  title: 'Corporate - Buildings Water Efficiency',
  description: 'Buildings Water Efficiency Corporate',
  certificate_type: Certificate.certificate_types[:building_water_efficiency_type],
  schemes: ['Typology'],
  applicability: Licence.applicabilities[:check_list]
)

# Events Carbon Neutrality
Licence.find_or_create_by!(
  licence_type: 'CorporateLicence',
  display_name: 'Corporate - Events Carbon Neutrality',
  display_weight: 7,
  title: 'Corporate - Events Carbon Neutrality',
  description: 'Events Carbon Neutrality Corporate',
  certificate_type: Certificate.certificate_types[:events_carbon_neutrality_type],
  schemes: ['Typology'],
  applicability: Licence.applicabilities[:check_list]
)

# Products Ecolabeling
Licence.find_or_create_by!(
  licence_type: 'CorporateLicence',
  display_name: 'Corporate - Products Ecolabeling',
  display_weight: 8,
  title: 'Corporate - Products Ecolabeling',
  description: 'Products Ecolabeling Corporate',
  certificate_type: Certificate.certificate_types[:products_ecolabeling_type],
  schemes: ['Typology'],
  applicability: Licence.applicabilities[:check_list]
)

# Green IT
Licence.find_or_create_by!(
  licence_type: 'CorporateLicence',
  display_name: 'Corporate - Green IT',
  display_weight: 9,
  title: 'Corporate - Green IT',
  description: 'Green IT Corporate',
  certificate_type: Certificate.certificate_types[:green_IT_type],
  schemes: ['Typology'],
  applicability: Licence.applicabilities[:check_list]
)

# Net Zero
Licence.find_or_create_by!(
  licence_type: 'CorporateLicence',
  display_name: 'Corporate - Net Zero',
  display_weight: 10,
  title: 'Corporate - Net Zero',
  description: 'Net Zero Corporate',
  certificate_type: Certificate.certificate_types[:net_zero_type],
  schemes: ['Typology'],
  applicability: Licence.applicabilities[:check_list]
)

# Energy Label - Waste Water Treatment Facility
Licence.find_or_create_by!(
  licence_type: 'CorporateLicence',
  display_name: 'Corporate - Energy Label - Waste Water Treatment Facility',
  display_weight: 11,
  title: 'Corporate - Energy Label - Waste Water Treatment Facility',
  description: 'Energy Label - Waste Water Treatment Facility Corporate',
  certificate_type: Certificate.certificate_types[:energy_label_waste_water_treatment_facility_type],
  schemes: ['Typology'],
  applicability: Licence.applicabilities[:check_list]
)


# ----------------------------------------- Licences for Certified Professional CGP -----------------------------------------
# Energy Centers Efficiency
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Energy Centers Efficiency',
  display_weight: 12,
  title: 'CGP - Energy Centers Efficiency',
  description: 'Energy Centers Efficiency Certified Green Professional',
  certificate_type: Certificate.certificate_types[:energy_centers_efficiency_type],
  applicability: Licence.applicabilities[:check_list]
)

# Building Energy Efficiency
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Building Energy Efficiency',
  display_weight: 13,
  title: 'CGP - Building Energy Efficiency',
  description: 'Building Energy Efficiency Certified Green Professional',
  certificate_type: Certificate.certificate_types[:building_energy_efficiency_type],
  applicability: Licence.applicabilities[:check_list]
)

# Healthy Buildings
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Healthy Buildings',
  display_weight: 14,
  title: 'CGP - Healthy Buildings',
  description: 'Healthy Buildings Certified Green Professional',
  certificate_type: Certificate.certificate_types[:healthy_buildings_type],
  applicability: Licence.applicabilities[:check_list]
)

# Indoor Air Quality
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Indoor Air Quality',
  display_weight: 15,
  title: 'CGP - Indoor Air Quality',
  description: 'Indoor Air Quality Certified Green Professional',
  certificate_type: Certificate.certificate_types[:indoor_air_quality_type],
  applicability: Licence.applicabilities[:check_list]
)

# Measurement, Reporting And Verification (MRV)
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Measurement, Reporting And Verification (MRV)',
  display_weight: 16,
  title: 'CGP - Measurement, Reporting And Verification (MRV)',
  description: 'Measurement, Reporting And Verification (MRV) Certified Green Professional',
  certificate_type: Certificate.certificate_types[:measurement_reporting_and_verification_type],
  applicability: Licence.applicabilities[:check_list]
)

# Buildings Water Efficiency
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Buildings Water Efficiency',
  display_weight: 17,
  title: 'CGP - Buildings Water Efficiency',
  description: 'Buildings Water Efficiency Certified Green Professional',
  certificate_type: Certificate.certificate_types[:building_water_efficiency_type],
  applicability: Licence.applicabilities[:check_list]
)

# Events Carbon Neutrality
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Events Carbon Neutrality',
  display_weight: 18,
  title: 'CGP - Events Carbon Neutrality',
  description: 'Events Carbon Neutrality Certified Green Professional',
  certificate_type: Certificate.certificate_types[:events_carbon_neutrality_type],
  applicability: Licence.applicabilities[:check_list]
)

# Products Ecolabeling
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Products Ecolabeling',
  display_weight: 19,
  title: 'CGP - Products Ecolabeling',
  description: 'Products Ecolabeling Certified Green Professional',
  certificate_type: Certificate.certificate_types[:products_ecolabeling_type],
  applicability: Licence.applicabilities[:check_list]
)

# Green IT
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Green IT',
  display_weight: 20,
  title: 'CGP - Green IT',
  description: 'Green IT Certified Green Professional',
  certificate_type: Certificate.certificate_types[:green_IT_type],
  applicability: Licence.applicabilities[:check_list]
)

# Net Zero
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Net Zero',
  display_weight: 21,
  title: 'CGP - Net Zero',
  description: 'Net Zero Certified Green Professional',
  certificate_type: Certificate.certificate_types[:net_zero_type],
  applicability: Licence.applicabilities[:check_list]
)

# Energy Label - Waste Water Treatment Facility
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Energy Label - Waste Water Treatment Facility',
  display_weight: 22,
  title: 'CGP - Energy Label - Waste Water Treatment Facility',
  description: 'Energy Label - Waste Water Treatment Facility Certified Green Professional',
  certificate_type: Certificate.certificate_types[:energy_label_waste_water_treatment_facility_type],
  applicability: Licence.applicabilities[:check_list]
)

# ----------------------------------------- Licences for Certified Professional CEP -----------------------------------------
# Energy Centers Efficiency
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Energy Centers Efficiency',
  display_weight: 23,
  title: 'CEP - Energy Centers Efficiency',
  description: 'Energy Centers Efficiency Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:energy_centers_efficiency_type],
  applicability: Licence.applicabilities[:check_list]
)

# Building Energy Efficiency
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Building Energy Efficiency',
  display_weight: 24,
  title: 'CEP - Building Energy Efficiency',
  description: 'Building Energy Efficiency Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:building_energy_efficiency_type],
  applicability: Licence.applicabilities[:check_list]
)

# Healthy Buildings
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Healthy Buildings',
  display_weight: 25,
  title: 'CEP - Healthy Buildings',
  description: 'Healthy Buildings Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:healthy_buildings_type],
  applicability: Licence.applicabilities[:check_list]
)

# Indoor Air Quality
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Indoor Air Quality',
  display_weight: 26,
  title: 'CEP - Indoor Air Quality',
  description: 'Indoor Air Quality Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:indoor_air_quality_type],
  applicability: Licence.applicabilities[:check_list]
)

# Measurement, Reporting And Verification (MRV)
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Measurement, Reporting And Verification (MRV)',
  display_weight: 27,
  title: 'CEP - Measurement, Reporting And Verification (MRV)',
  description: 'Measurement, Reporting And Verification (MRV) Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:measurement_reporting_and_verification_type],
  applicability: Licence.applicabilities[:check_list]
)

# Buildings Water Efficiency
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Buildings Water Efficiency',
  display_weight: 28,
  title: 'CEP - Buildings Water Efficiency',
  description: 'Buildings Water Efficiency Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:building_water_efficiency_type],
  applicability: Licence.applicabilities[:check_list]
)

# Events Carbon Neutrality
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Events Carbon Neutrality',
  display_weight: 29,
  title: 'CEP - Events Carbon Neutrality',
  description: 'Events Carbon Neutrality Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:events_carbon_neutrality_type],
  applicability: Licence.applicabilities[:check_list]
)

# Products Ecolabeling
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Products Ecolabeling',
  display_weight: 30,
  title: 'CEP - Products Ecolabeling',
  description: 'Products Ecolabeling Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:products_ecolabeling_type],
  applicability: Licence.applicabilities[:check_list]
)

# Green IT
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Green IT',
  display_weight: 31,
  title: 'CEP - Green IT',
  description: 'Green IT Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:green_IT_type],
  applicability: Licence.applicabilities[:check_list]
)

# Net Zero
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Net Zero',
  display_weight: 32,
  title: 'CEP - Net Zero',
  description: 'Net Zero Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:net_zero_type],
  applicability: Licence.applicabilities[:check_list]
)

# Energy Label - Waste Water Treatment Facility
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Energy Label - Waste Water Treatment Facility',
  display_weight: 33,
  title: 'CEP - Energy Label - Waste Water Treatment Facility',
  description: 'Energy Label - Waste Water Treatment Facility Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:energy_label_waste_water_treatment_facility_type],
  applicability: Licence.applicabilities[:check_list]
)


