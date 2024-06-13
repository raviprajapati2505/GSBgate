class Certificate < ApplicationRecord
  enum certificate_type: [ 
    :energy_centers_efficiency_type,
    :building_energy_efficiency_type,
    :healthy_buildings_type,
    :indoor_air_quality_type,
    :measurement_reporting_and_verification_type,
    :building_water_efficiency_type,
    :events_carbon_neutrality_type,
    :products_ecolabeling_type,
    :green_IT_type,
    :net_zero_type,
    :energy_label_waste_water_treatment_facility_type
  ]

  enum assessment_stage: [ 
    :energy_centers_efficiency_stage,
    :building_energy_efficiency_stage,
    :healthy_buildings_stage,
    :indoor_air_quality_stage,
    :measurement_reporting_and_verification_stage,
    :building_water_efficiency_stage,
    :events_carbon_neutrality_stage,
    :products_ecolabeling_stage,
    :green_IT_stage,
    :net_zero_stage,
    :energy_label_waste_water_treatment_facility_stage
  ]

  enum certification_type: [ 
    :provisional_energy_centers_efficiency,
    :provisional_building_energy_efficiency,
    :provisional_healthy_buildings,
    :provisional_indoor_air_quality,
    :provisional_measurement_reporting_and_verification,
    :provisional_building_water_efficiency,
    :provisional_events_carbon_neutrality,
    :provisional_products_ecolabeling,
    :provisional_green_IT,
    :provisional_net_zero,
    :provisional_energy_label_waste_water_treatment_facility,
    :final_energy_centers_efficiency,
    :final_building_energy_efficiency,
    :final_healthy_buildings,
    :final_indoor_air_quality,
    :final_measurement_reporting_and_verification,
    :final_building_water_efficiency,
    :final_events_carbon_neutrality,
    :final_products_ecolabeling,
    :final_green_IT,
    :final_net_zero,
    :final_energy_label_waste_water_treatment_facility
  ]

  PROVISIONAL_CERTIFICATES = [
    :provisional_energy_centers_efficiency,
    :provisional_building_energy_efficiency,
    :provisional_healthy_buildings,
    :provisional_indoor_air_quality,
    :provisional_measurement_reporting_and_verification,
    :provisional_building_water_efficiency,
    :provisional_events_carbon_neutrality,
    :provisional_products_ecolabeling,
    :provisional_green_IT,
    :provisional_net_zero,
    :provisional_energy_label_waste_water_treatment_facility
  ]
  PROVISIONAL_CERTIFICATES_VALUES = certification_types.select{ |k, v| v if k.include?("provisional_")}&.values

  FINAL_CERTIFICATES = [
    :final_energy_centers_efficiency,
    :final_building_energy_efficiency,
    :final_healthy_buildings,
    :final_indoor_air_quality,
    :final_measurement_reporting_and_verification,
    :final_building_water_efficiency,
    :final_events_carbon_neutrality,
    :final_products_ecolabeling,
    :final_green_IT,
    :final_net_zero,
    :final_energy_label_waste_water_treatment_facility
  ]
  FINAL_CERTIFICATES_VALUES = certification_types.select{ |k, v| v if k.include?("final_")}&.values

  has_many :certification_paths
  has_many :development_types

  validates_inclusion_of :certificate_type, in: Certificate.certificate_types.keys
  validates_inclusion_of :assessment_stage, in: Certificate.assessment_stages.keys
  validates_inclusion_of :certification_type, in: Certificate.certification_types.keys

  scope :with_gsb_version, ->(gsb_version) {
    where(gsb_version: gsb_version)
  }

  scope :with_certification_type, ->(certification_type) {
    where(certification_type: certification_type)
  }

  def energy_centers_efficiency?
    energy_centers_efficiency_type?
  end

  def building_energy_efficiency?
    building_energy_efficiency_type?
  end

  def healthy_buildings?
    healthy_buildings_type?
  end

  def indoor_air_quality?
    indoor_air_quality_type?
  end

  def measurement_reporting_and_verification?
    measurement_reporting_and_verification_type?
  end

  def building_water_efficiency_efficiency?
    building_water_efficiency_efficiency_type?
  end

  def events_carbon_neutrality?
    events_carbon_neutrality_type?
  end

  def products_ecolabeling?
    products_ecolabeling_type?
  end

  def green_IT?
    green_IT_type?
  end

  def net_zero?
    net_zero_type?
  end

  def energy_label_waste_water_treatment_facility?
    energy_label_waste_water_treatment_facility_type?
  end

  def full_name
    self.name
  end

  def self.get_certification_types(certificate_types)
    certificate_types_array = []
    certificate_types.each do |certificate_type|
      next unless certificate_type.present?
      certificate_types_array.push(*
                              case certificate_type
                              when "energy_centers_efficiency_type"
                                [Certificate.certification_types[:provisional_energy_centers_efficiency], Certificate.certification_types[:final_energy_centers_efficiency]]
                              when "building_energy_efficiency_type"
                                [Certificate.certification_types[:provisional_building_energy_efficiency], Certificate.certification_types[:final_building_energy_efficiency]]
                              when "healthy_buildings_type"
                                [Certificate.certification_types[:provisional_healthy_buildings], Certificate.certification_types[:final_healthy_buildings]]
                              when "indoor_air_quality_type"
                                [Certificate.certification_types[:provisional_indoor_air_quality], Certificate.certification_types[:final_indoor_air_quality]]
                              when "measurement_reporting_and_verification_type"
                                [Certificate.certification_types[:provisional_measurement_reporting_and_verification], Certificate.certification_types[:final_measurement_reporting_and_verification]]
                              when "building_water_efficiency_type"
                                [Certificate.certification_types[:provisional_building_water_efficiency], Certificate.certification_types[:final_building_water_efficiency]]
                              when "events_carbon_neutrality_type"
                                [Certificate.certification_types[:provisional_events_carbon_neutrality], Certificate.certification_types[:final_events_carbon_neutrality]]
                              when "products_ecolabeling_type"
                                [Certificate.certification_types[:provisional_products_ecolabeling], Certificate.certification_types[:final_products_ecolabeling]]
                              when "green_IT_type"
                                [Certificate.certification_types[:provisional_green_IT], Certificate.certification_types[:final_green_IT]]
                              when "net_zero_type"
                                [Certificate.certification_types[:provisional_net_zero], Certificate.certification_types[:final_net_zero]]
                              when "energy_label_waste_water_treatment_facility_type"
                                [Certificate.certification_types[:provisional_energy_label_waste_water_treatment_facility], Certificate.certification_types[:final_energy_label_waste_water_treatment_facility]]
                              else
                                Certificate.certification_types
                              end
                            )
    end

    return certificate_types_array
  end

  def self.get_certificate_by_stage(certificate_stages)
    certificate_stages_array = []
    certificate_stages.each do |certificate_stage|
      next unless certificate_stage.present?
      certificate_stages_array.push(
                                      case certificate_stage
                                      when "Stage 1: Provisional Certificate"
                                        Certificate::PROVISIONAL_CERTIFICATES_VALUES
                                      when "Stage 2: Final Certificate"
                                        Certificate::FINAL_CERTIFICATES_VALUES
                                      else
                                        Certificate.certification_types
                                      end
                                   )
    end
    return certificate_stages_array
  end

  def only_certification_name
    I18n.t("activerecord.attributes.certificate.certificate_types.certificate_titles.#{only_name}")
  end

  def report_certification_name
    I18n.t("activerecord.attributes.certificate.certificate_types.certificate_titles.#{only_name}")
  end

  def only_name
    name = 
      if certification_type.include?('provisional_')
        certification_type.gsub("provisional_", "")
      elsif certification_type.include?('final_')
        certification_type.gsub("final_", "")
      end
  end

  def only_version
    gsb_version
  end

  def team_title
    I18n.t("activerecord.attributes.project.team_titles.#{certification_type}")
  end
end
