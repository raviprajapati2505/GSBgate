# Update all certificates to fixed enum

def only_name(certification_type)
  if certification_type.include?('provisional_')
    certification_type.gsub("provisional_", "")
  elsif certification_type.include?('final_')
    certification_type.gsub("final_", "")
  end
end

def stage_certificate(certification_type)
  if certification_type.include?('provisional_')
    "Stage 1: Provisional Certificate"
  elsif certification_type.include?('final_')
    "Stage 2: Final Certificate"
  end
end

Certificate.certification_types.each do |certification_key, _ |
  certificate = Certificate.find_by(certification_type: certification_key)
  name = stage_certificate(certification_key)
  certificate_type = "#{only_name(certification_key)}_type"
  assessment_stage = "#{only_name(certification_key)}_stage"
  certificate.update_column(:name, name)
  certificate.update_column(:certificate_type, Certificate.certificate_types[certificate_type])
  certificate.update_column(:assessment_stage, Certificate.assessment_stages[assessment_stage])
end

Certificate.certification_types.each do |certification_key,certification_value|
  scheme = Scheme.find_by(certification_type: certification_value)
  certificate_type = "#{only_name(certification_key)}_type"
  scheme.update_column(:certificate_type, Certificate.certificate_types[certificate_type])
end

# Destroy invalid certificates
# Step 1: Get valid enum values (integers)
valid_enum_values = Certificate.certification_types.values

# Step 2: Find certificates with invalid or nil enum values
invalid_schemes = Scheme.where.not(certification_type: valid_enum_values)
invalid_certificates = Certificate.where.not(certification_type: valid_enum_values)

# Step 3: Delete them
invalid_schemes.find_each(&:destroy)
invalid_certificates.find_each(&:destroy)

# Destory Licences

certificate_types = {
  building_energy_efficiency: "Building Energy Efficiency",
  healthy_building: "Healthy Buildings",
  indoor_air_quality: "Indoor Air Quality",
  energy_label_waste_water_treatment_facility: "Energy Label - Waste Water Treatment Facility"
}

certificate_types.keys.each_with_index do |type_key, index|
  Licence.find_by(
    licence_type: 'CorporateLicence',
    display_name: "Corporate - #{certificate_types[type_key]}"
  )&.destroy
end

certificate_types.each_with_index do |(type_key, display_name), index|
  Licence.find_by(
    licence_type: 'CgpLicence',
    display_name: "CGP - #{display_name}"
   )&.destroy
end

certificate_types.each_with_index do |(type_key, display_name), index|
  Licence.find_by(
    licence_type: 'CepLicence',
    display_name: "CEP - #{display_name}"
  )&.destroy
end

# Update Licences (Energy Building -> Net-Zero Energy)

licence = Licence.find_by(
  licence_type: 'CorporateLicence',
  display_name: "Corporate - Energy Building"
)
licence&.update_column(:display_name, "Corporate - Net-Zero Energy")

licence = Licence.find_by(
  licence_type: 'CgpLicence',
  display_name: "CGP - Energy Building"
)
licence&.update_column(:display_name, "CGP - Net-Zero Energy")

licence = Licence.find_by(
  licence_type: 'CepLicence',
  display_name: "CEP - Energy Building"
)
licence&.update_column(:display_name, "CEP - Net-Zero Energy")

# Fix Certificate Type as per display name
CERTIFICATE_TYPE_SYMBOLS = {
  'Energy Centers Efficiency' => :energy_centers_efficiency,
  'Measurement, Reporting And Verification (MRV)' => :measurement_reporting_and_verification,
  'Buildings Water Efficiency' => :building_water_efficiency,
  'Events Carbon Neutrality' => :events_carbon_neutrality,
  'Products Ecolabeling' => :products_ecolabeling,
  'Green IT' => :green_IT,
  'Net-Zero Energy' => :net_zero_energy,
  'Energy Label for Building Performance' => :energy_label_for_building_performance,
  'Indoor Air Quality (IAQ) Certification' => :indoor_air_quality_certification,
  'Indoor Environmental Quality (IEQ) Certification' => :indoor_environmental_quality_certification,
  'Energy Label for Wastewater Treatment Plant (WTP)' => :energy_label_for_wastewater_treatment_plant,
  'Energy Label for Leachate Treatment Plant (LTP)' => :energy_label_for_leachate_treatment_plant,
  'Healthy Building Label' => :healthy_building_label,
  'Energy label for Industrial application' => :energy_label_for_industrial_application,
  'Energy label for Infrastructure projects' => :energy_label_for_infrastructure_projects
}.freeze

Licence.where(licence_type: 'CorporateLicence').each do |licence|
  display_name = licence.display_name
  display_name = display_name.gsub("Corporate - ", "")
  title = "Corporate - #{display_name}"
  description = "#{display_name} Corporate"
  certificate_type = Certificate.certificate_types["#{CERTIFICATE_TYPE_SYMBOLS[display_name]}_type"]
  licence.update_column(:title, title)
  licence.update_column(:description, description)
  licence.update_column(:certificate_type, certificate_type)
end
  
Licence.where(licence_type: 'CgpLicence').each do |licence|
  display_name = licence.display_name
  display_name = display_name.gsub("CGP - ", "")
  title = "CGP - #{display_name}"
  description = "#{display_name} Certified Green Professional"
  certificate_type = Certificate.certificate_types["#{CERTIFICATE_TYPE_SYMBOLS[display_name]}_type"]
  licence.update_column(:title, title)
  licence.update_column(:description, description)
  licence.update_column(:certificate_type, certificate_type)
end
  
Licence.where(licence_type: 'CepLicence').each do |licence|
  display_name = licence.display_name
  display_name = display_name.gsub("CEP - ", "")
  title = "CEP - #{display_name}"
  description = "#{display_name} Certified Energy Professional"
  certificate_type = Certificate.certificate_types["#{CERTIFICATE_TYPE_SYMBOLS[display_name]}_type"]
  licence.update_column(:title, title)
  licence.update_column(:description, description)
  licence.update_column(:certificate_type, certificate_type)
end
  