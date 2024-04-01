# ----------------------------------------- Licences for Service Providers -----------------------------------------
# Energy Centers Efficiency
Licence.find_or_create_by!(
  licence_type: 'ServiceProviderLicence',
  display_name: 'Service Provider - Energy Centers Efficiency',
  display_weight: 1,
  title: 'Service Provider - Energy Centers Efficiency',
  description: 'Energy Centers Efficiency Service Provider',
  certificate_type: Certificate.certificate_types[:energy_centers_efficiency_type],
  schemes: ['Typology']
)

# Building Energy Efficiency
Licence.find_or_create_by!(
  licence_type: 'ServiceProviderLicence',
  display_name: 'Service Provider - Building Energy Efficiency',
  display_weight: 2,
  title: 'Service Provider - Building Energy Efficiency',
  description: 'Building Energy Efficiency Service Provider',
  certificate_type: Certificate.certificate_types[:building_energy_efficiency_type],
  schemes: ['Typology']
)

# Healthy Buildings
Licence.find_or_create_by!(
  licence_type: 'ServiceProviderLicence',
  display_name: 'Service Provider - Healthy Buildings',
  display_weight: 3,
  title: 'Service Provider - Healthy Buildings',
  description: 'Healthy Buildings Service Provider',
  certificate_type: Certificate.certificate_types[:healthy_buildings_type],
  schemes: ['Typology']
)

# Indoor Air Quality
Licence.find_or_create_by!(
  licence_type: 'ServiceProviderLicence',
  display_name: 'Service Provider - Indoor Air Quality',
  display_weight: 3,
  title: 'Service Provider - Indoor Air Quality',
  description: 'Indoor Air Quality Service Provider',
  certificate_type: Certificate.certificate_types[:indoor_air_quality_type],
  schemes: ['Typology']
)

# Measurement, Reporting And Verification (MRV)
Licence.find_or_create_by!(
  licence_type: 'ServiceProviderLicence',
  display_name: 'Service Provider - Measurement, Reporting And Verification (MRV)',
  display_weight: 3,
  title: 'Service Provider - Measurement, Reporting And Verification (MRV)',
  description: 'Measurement, Reporting And Verification (MRV) Service Provider',
  certificate_type: Certificate.certificate_types[:measurement_reporting_and_verification_type],
  schemes: ['Typology']
)

# Buildings Water Efficiency
Licence.find_or_create_by!(
  licence_type: 'ServiceProviderLicence',
  display_name: 'Service Provider - Buildings Water Efficiency',
  display_weight: 3,
  title: 'Service Provider - Buildings Water Efficiency',
  description: 'Buildings Water Efficiency Service Provider',
  certificate_type: Certificate.certificate_types[:building_water_efficiency_type],
  schemes: ['Typology']
)

# Events Carbon Neutrality
Licence.find_or_create_by!(
  licence_type: 'ServiceProviderLicence',
  display_name: 'Service Provider - Events Carbon Neutrality',
  display_weight: 3,
  title: 'Service Provider - Events Carbon Neutrality',
  description: 'Events Carbon Neutrality Service Provider',
  certificate_type: Certificate.certificate_types[:events_carbon_neutrality_type],
  schemes: ['Typology']
)

# Products Ecolabeling
Licence.find_or_create_by!(
  licence_type: 'ServiceProviderLicence',
  display_name: 'Service Provider - Products Ecolabeling',
  display_weight: 3,
  title: 'Service Provider - Products Ecolabeling',
  description: 'Products Ecolabeling Service Provider',
  certificate_type: Certificate.certificate_types[:products_ecolabeling_type],
  schemes: ['Typology']
)

# Green IT
Licence.find_or_create_by!(
  licence_type: 'ServiceProviderLicence',
  display_name: 'Service Provider - Green IT',
  display_weight: 3,
  title: 'Service Provider - Green IT',
  description: 'Green IT Service Provider',
  certificate_type: Certificate.certificate_types[:green_IT_type],
  schemes: ['Typology']
)

# Net Zero
Licence.find_or_create_by!(
  licence_type: 'ServiceProviderLicence',
  display_name: 'Service Provider - Net Zero',
  display_weight: 3,
  title: 'Service Provider - Net Zero',
  description: 'Net Zero Service Provider',
  certificate_type: Certificate.certificate_types[:net_zero_type],
  schemes: ['Typology']
)


# ----------------------------------------- Licences for Certified Professional CGP -----------------------------------------
# Energy Centers Efficiency
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Energy Centers Efficiency',
  display_weight: 4,
  title: 'CGP - Energy Centers Efficiency',
  description: 'Energy Centers Efficiency Certified Green Professional',
  certificate_type: Certificate.certificate_types[:energy_centers_efficiency_type],
  applicability: Licence.applicabilities[:star_rating]
)

# Building Energy Efficiency
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Building Energy Efficiency',
  display_weight: 9,
  title: 'CGP - Building Energy Efficiency',
  description: 'Building Energy Efficiency Certified Green Professional',
  certificate_type: Certificate.certificate_types[:building_energy_efficiency_type],
  applicability: Licence.applicabilities[:star_rating]
)

# Healthy Buildings
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Healthy Buildings',
  display_weight: 9,
  title: 'CGP - Healthy Buildings',
  description: 'Healthy Buildings Certified Green Professional',
  certificate_type: Certificate.certificate_types[:healthy_buildings_type],
  applicability: Licence.applicabilities[:star_rating]
)

# Indoor Air Quality
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Indoor Air Quality',
  display_weight: 9,
  title: 'CGP - Indoor Air Quality',
  description: 'Indoor Air Quality Certified Green Professional',
  certificate_type: Certificate.certificate_types[:indoor_air_quality_type],
  applicability: Licence.applicabilities[:star_rating]
)

# Measurement, Reporting And Verification (MRV)
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Measurement, Reporting And Verification (MRV)',
  display_weight: 9,
  title: 'CGP - Measurement, Reporting And Verification (MRV)',
  description: 'Measurement, Reporting And Verification (MRV) Certified Green Professional',
  certificate_type: Certificate.certificate_types[:measurement_reporting_and_verification_type],
  applicability: Licence.applicabilities[:star_rating]
)

# Buildings Water Efficiency
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Buildings Water Efficiency',
  display_weight: 9,
  title: 'CGP - Buildings Water Efficiency',
  description: 'Buildings Water Efficiency Certified Green Professional',
  certificate_type: Certificate.certificate_types[:building_water_efficiency_type],
  applicability: Licence.applicabilities[:star_rating]
)

# Events Carbon Neutrality
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Events Carbon Neutrality',
  display_weight: 9,
  title: 'CGP - Events Carbon Neutrality',
  description: 'Events Carbon Neutrality Certified Green Professional',
  certificate_type: Certificate.certificate_types[:events_carbon_neutrality_type],
  applicability: Licence.applicabilities[:star_rating]
)

# Products Ecolabeling
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Products Ecolabeling',
  display_weight: 9,
  title: 'CGP - Products Ecolabeling',
  description: 'Products Ecolabeling Certified Green Professional',
  certificate_type: Certificate.certificate_types[:products_ecolabeling_type],
  applicability: Licence.applicabilities[:star_rating]
)

# Green IT
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Green IT',
  display_weight: 9,
  title: 'CGP - Green IT',
  description: 'Green IT Certified Green Professional',
  certificate_type: Certificate.certificate_types[:green_IT_type],
  applicability: Licence.applicabilities[:star_rating]
)

# Net Zero
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'CGP - Net Zero',
  display_weight: 9,
  title: 'CGP - Net Zero',
  description: 'Net Zero Certified Green Professional',
  certificate_type: Certificate.certificate_types[:net_zero_type],
  applicability: Licence.applicabilities[:star_rating]
)


# ----------------------------------------- Licences for Certified Professional CEP -----------------------------------------
# Energy Centers Efficiency
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Energy Centers Efficiency',
  display_weight: 16,
  title: 'CEP - Energy Centers Efficiency',
  description: 'Energy Centers Efficiency Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:energy_centers_efficiency_type],
  applicability: Licence.applicabilities[:star_rating]
)

# Building Energy Efficiency
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Building Energy Efficiency',
  display_weight: 16,
  title: 'CEP - Building Energy Efficiency',
  description: 'Building Energy Efficiency Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:building_energy_efficiency_type],
  applicability: Licence.applicabilities[:star_rating]
)

# Healthy Buildings
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Healthy Buildings',
  display_weight: 16,
  title: 'CEP - Healthy Buildings',
  description: 'Healthy Buildings Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:healthy_buildings_type],
  applicability: Licence.applicabilities[:star_rating]
)

# Indoor Air Quality
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Indoor Air Quality',
  display_weight: 16,
  title: 'CEP - Indoor Air Quality',
  description: 'Indoor Air Quality Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:indoor_air_quality_type],
  applicability: Licence.applicabilities[:star_rating]
)

# Measurement, Reporting And Verification (MRV)
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Measurement, Reporting And Verification (MRV)',
  display_weight: 16,
  title: 'CEP - Measurement, Reporting And Verification (MRV)',
  description: 'Measurement, Reporting And Verification (MRV) Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:measurement_reporting_and_verification_type],
  applicability: Licence.applicabilities[:star_rating]
)

# Buildings Water Efficiency
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Buildings Water Efficiency',
  display_weight: 16,
  title: 'CEP - Buildings Water Efficiency',
  description: 'Buildings Water Efficiency Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:building_water_efficiency_type],
  applicability: Licence.applicabilities[:star_rating]
)

# Events Carbon Neutrality
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Events Carbon Neutrality',
  display_weight: 16,
  title: 'CEP - Events Carbon Neutrality',
  description: 'Events Carbon Neutrality Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:events_carbon_neutrality_type],
  applicability: Licence.applicabilities[:star_rating]
)

# Products Ecolabeling
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Products Ecolabeling',
  display_weight: 16,
  title: 'CEP - Products Ecolabeling',
  description: 'Products Ecolabeling Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:products_ecolabeling_type],
  applicability: Licence.applicabilities[:star_rating]
)

# Green IT
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Green IT',
  display_weight: 16,
  title: 'CEP - Green IT',
  description: 'Green IT Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:green_IT_type],
  applicability: Licence.applicabilities[:star_rating]
)

# Net Zero
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'CEP - Net Zero',
  display_weight: 16,
  title: 'CEP - Net Zero',
  description: 'Net Zero Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:net_zero_type],
  applicability: Licence.applicabilities[:star_rating]
)

