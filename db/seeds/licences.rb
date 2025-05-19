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

# Energy Building
Licence.find_or_create_by!(
  licence_type: 'CorporateLicence',
  display_name: 'Corporate - Energy Building',
  display_weight: 10,
  title: 'Corporate - Energy Building',
  description: 'Energy Building Corporate',
  certificate_type: Certificate.certificate_types[:energy_building_type],
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

# Energy Building
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Energy Building',
  display_weight: 21,
  title: 'CGP - Energy Building',
  description: 'Energy Building Certified Green Professional',
  certificate_type: Certificate.certificate_types[:energy_building_type],
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

# Energy Building
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Energy Building',
  display_weight: 32,
  title: 'CEP - Energy Building',
  description: 'Energy Building Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:energy_building_type],
  applicability: Licence.applicabilities[:check_list]
)
