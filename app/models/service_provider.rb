class ServiceProvider < User
  has_one :service_provider_detail, dependent: :destroy, inverse_of: :service_provider
  has_many :users, class_name: 'User', foreign_key: 'service_provider_id', dependent: :destroy

  accepts_nested_attributes_for :service_provider_detail

  def valid_service_provider_licences
    access_licences
      .joins(:licence)
      .where(
        "DATE(access_licences.expiry_date) > :current_date 
        AND licences.licence_type = 'ServiceProviderLicence'", 
        current_date: Date.today
      ) || AccessLicence.none
  end

  def valid_cgps
    users
      .joins("INNER JOIN access_licences on access_licences.user_id = users.id")
      .joins("INNER JOIN licences on licences.id = access_licences.licence_id")
      .where(
        "DATE(access_licences.expiry_date) > :current_date 
        AND licences.licence_type = 'CgpLicence' 
        AND users.active = true", 
        current_date: Date.today
      ) || AccessLicence.none
  end

  def valid_ceps
    users
      .joins("INNER JOIN access_licences on access_licences.user_id = users.id")
      .joins("INNER JOIN licences on licences.id = access_licences.licence_id")
      .where(
        "DATE(access_licences.expiry_date) > :current_date 
        AND licences.licence_type = 'CepLicence' 
        AND users.active = true", 
        current_date: Date.today
      ) || AccessLicence.none
  end

  # ------------------------- Checks for Energy Centers Efficiency ---------------------------
  def valid_service_provider_energy_centers_efficiency_licences
    access_licences
      .valid_service_provider_licences_with_type(Certificate.certificate_types[:energy_centers_efficiency_type])
      || AccessLicence.none
  end

  def valid_energy_centers_efficiency_cgps
    users
      .valid_cgps_with_type(Certificate.certificate_types[:energy_centers_efficiency_type])
      || AccessLicence.none
  end

  def valid_energy_centers_efficiency_ceps
    users
      .valid_ceps_with_type(Certificate.certificate_types[:energy_centers_efficiency_type]) 
      || AccessLicence.none
  end

  # ------------------------- Checks for Building Energy Efficiency ---------------------------
  def valid_service_provider_building_energy_efficiency_licences
    access_licences
      .valid_service_provider_licences_with_type(Certificate.certificate_types[:building_energy_efficiency_type])
      || AccessLicence.none
  end

  def valid_building_energy_efficiency_cgps
    users
      .valid_cgps_with_type(Certificate.certificate_types[:building_energy_efficiency_type])
      || AccessLicence.none
  end

  def valid_building_energy_efficiency_ceps
    users
      .valid_ceps_with_type(Certificate.certificate_types[:building_energy_efficiency_type]) 
      || AccessLicence.none
  end

  # ------------------------- Checks for Healthy Buildings ---------------------------
  def valid_service_provider_healthy_buildings_licences
    access_licences
      .valid_service_provider_licences_with_type(Certificate.certificate_types[:healthy_buildings_type])
      || AccessLicence.none
  end

  def valid_healthy_buildings_cgps
    users
      .valid_cgps_with_type(Certificate.certificate_types[:healthy_buildings_type])
      || AccessLicence.none
  end

  def valid_healthy_buildings_ceps
    users
      .valid_ceps_with_type(Certificate.certificate_types[:healthy_buildings_type]) 
      || AccessLicence.none
  end

  # ------------------------- Checks for Indoor Air Quality ---------------------------
  def valid_service_provider_indoor_air_quality_licences
    access_licences
      .valid_service_provider_licences_with_type(Certificate.certificate_types[:indoor_air_quality_type])
      || AccessLicence.none
  end

  def valid_indoor_air_quality_cgps
    users
      .valid_cgps_with_type(Certificate.certificate_types[:indoor_air_quality_type])
      || AccessLicence.none
  end

  def valid_indoor_air_quality_ceps
    users
      .valid_ceps_with_type(Certificate.certificate_types[:indoor_air_quality_type]) 
      || AccessLicence.none
  end

  # ------------------------- Checks for Measurement, Reporting And Verification (MRV) ---------------------------
  def valid_service_provider_measurement_reporting_and_verification_licences
    access_licences
      .valid_service_provider_licences_with_type(Certificate.certificate_types[:measurement_reporting_and_verification_type])
      || AccessLicence.none
  end

  def valid_measurement_reporting_and_verification_cgps
    users
      .valid_cgps_with_type(Certificate.certificate_types[:measurement_reporting_and_verification_type])
      || AccessLicence.none
  end

  def valid_measurement_reporting_and_verification_ceps
    users
      .valid_ceps_with_type(Certificate.certificate_types[:measurement_reporting_and_verification_type]) 
      || AccessLicence.none
  end

  # ------------------------- Checks for Buildings Water Efficiency ---------------------------
  def valid_service_provider_building_water_efficiency_licences
    access_licences
      .valid_service_provider_licences_with_type(Certificate.certificate_types[:building_water_efficiency_type])
      || AccessLicence.none
  end

  def valid_building_water_efficiency_cgps
    users
      .valid_cgps_with_type(Certificate.certificate_types[:building_water_efficiency_type])
      || AccessLicence.none
  end

  def valid_building_water_efficiency_ceps
    users
      .valid_ceps_with_type(Certificate.certificate_types[:building_water_efficiency_type]) 
      || AccessLicence.none
  end

  # ------------------------- Checks for Events Carbon Neutrality ---------------------------
  def valid_service_provider_events_carbon_neutrality_licences
    access_licences
      .valid_service_provider_licences_with_type(Certificate.certificate_types[:events_carbon_neutrality_type])
      || AccessLicence.none
  end

  def valid_events_carbon_neutrality_cgps
    users
      .valid_cgps_with_type(Certificate.certificate_types[:events_carbon_neutrality_type])
      || AccessLicence.none
  end

  def valid_events_carbon_neutrality_ceps
    users
      .valid_ceps_with_type(Certificate.certificate_types[:events_carbon_neutrality_type]) 
      || AccessLicence.none
  end

  # ------------------------- Checks for Products Ecolabeling ---------------------------
  def valid_service_provider_products_ecolabeling_licences
    access_licences
      .valid_service_provider_licences_with_type(Certificate.certificate_types[:products_ecolabeling_type])
      || AccessLicence.none
  end

  def valid_products_ecolabeling_cgps
    users
      .valid_cgps_with_type(Certificate.certificate_types[:products_ecolabeling_type])
      || AccessLicence.none
  end

  def valid_products_ecolabeling_ceps
    users
      .valid_ceps_with_type(Certificate.certificate_types[:products_ecolabeling_type]) 
      || AccessLicence.none
  end

  # ------------------------- Checks for Green IT ---------------------------
  def valid_service_provider_green_IT_licences
    access_licences
      .valid_service_provider_licences_with_type(Certificate.certificate_types[:green_IT_type])
      || AccessLicence.none
  end

  def valid_green_IT_cgps
    users
      .valid_cgps_with_type(Certificate.certificate_types[:green_IT_type])
      || AccessLicence.none
  end

  def valid_green_IT_ceps
    users
      .valid_ceps_with_type(Certificate.certificate_types[:green_IT_type]) 
      || AccessLicence.none
  end

  # ------------------------- Checks for Net Zero ---------------------------
  def valid_service_provider_net_zero_licences
    access_licences
      .valid_service_provider_licences_with_type(Certificate.certificate_types[:net_zero_type])
      || AccessLicence.none
  end

  def valid_net_zero_cgps
    users
      .valid_cgps_with_type(Certificate.certificate_types[:net_zero_type])
      || AccessLicence.none
  end

  def valid_net_zero_ceps
    users
      .valid_ceps_with_type(Certificate.certificate_types[:net_zero_type]) 
      || AccessLicence.none
  end
end
