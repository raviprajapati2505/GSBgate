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
  healthy_building: "Healthy Building",
  indoor_air_quality: "Indoor Air Quality",
  energy_label_waste_water_treatment_facility: "Energy Label Waste Water Treatment Facility"
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

# Update Licences (Net Zero -> Energy Building)

licence = Licence.find_by(
  licence_type: 'CorporateLicence',
  display_name: "Corporate - Net Zero"
)
licence.update_column(:display_name, "Corporate - Energy Building")

licence = Licence.find_by(
  licence_type: 'CgpLicence',
  display_name: "CGP - Net Zero"
)
licence.update_column(:display_name, "CGP - Energy Building")

licence = Licence.find_by(
  licence_type: 'CepLicence',
  display_name: "CEP - Net Zero"
)
licence.update_column(:display_name, "CEP - Energy Building")