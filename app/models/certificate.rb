class Certificate < ApplicationRecord
  CERTIFICATE_TYPES = %i[
    energy_centers_efficiency
    measurement_reporting_and_verification
    building_water_efficiency
    events_carbon_neutrality
    products_ecolabeling
    green_IT
    energy_building
    energy_label_for_building_performance
    indoor_air_quality_certification
    indoor_environmental_quality_certification
    energy_label_for_wastewater_treatment_plant
    energy_label_for_leachate_treatment_plant
    healthy_building_label
    energy_label_for_industrial_application
    energy_label_for_infrastructure_projects
  ].freeze

  CERTIFICATION_MAPPINGS = {
    'Energy Centers Efficiency' => 'db',
    'Measurement, Reporting And Verification (MRV)' => 'db',
    'Buildings Water Efficiency' => 'cm',
    'Events Carbon Neutrality' => 'op',
    'Products Ecolabeling' => 'db',
    'Green IT' => 'op',
    'Energy Building' => 'db',
    'Energy Label for Building Performance' => 'cm',
    'Indoor Air Quality (IAQ) Certification' => 'db',
    'Indoor Environmental Quality (IEQ) Certification' => 'cm',
    'Energy Label for Wastewater Treatment Plant (WTP)' => 'op',
    'Energy Label for Leachate Treatment Plant (LTP)' => 'db',
    'Healthy Building Label' => 'op',
    'Energy label for Industrial application' => 'cm',
    'Energy label for Infrastructure projects' => 'op'
  }.freeze

  enum certificate_type: [ 
    :energy_centers_efficiency_type,
    :measurement_reporting_and_verification_type,
    :building_water_efficiency_type,
    :events_carbon_neutrality_type,
    :products_ecolabeling_type,
    :green_IT_type,
    :energy_building_type,
    :energy_label_for_building_performance_type,
    :indoor_air_quality_certification_type,
    :indoor_environmental_quality_certification_type,
    :energy_label_for_wastewater_treatment_plant_type,
    :energy_label_for_leachate_treatment_plant_type,
    :healthy_building_label_type,
    :energy_label_for_industrial_application_type,
    :energy_label_for_infrastructure_projects_type
  ]

  enum assessment_stage: [ 
    :energy_centers_efficiency_stage,
    :measurement_reporting_and_verification_stage,
    :building_water_efficiency_stage,
    :events_carbon_neutrality_stage,
    :products_ecolabeling_stage,
    :green_IT_stage,
    :energy_building_stage,
    :energy_label_for_building_performance_stage,
    :indoor_air_quality_certification_stage,
    :indoor_environmental_quality_certification_stage,
    :energy_label_for_wastewater_treatment_plant_stage,
    :energy_label_for_leachate_treatment_plant_stage,
    :healthy_building_label_stage,
    :energy_label_for_industrial_application_stage,
    :energy_label_for_infrastructure_projects_stage
  ]

  enum certification_type: [ 
    :provisional_energy_centers_efficiency,
    :provisional_measurement_reporting_and_verification,
    :provisional_building_water_efficiency,
    :provisional_events_carbon_neutrality,
    :provisional_products_ecolabeling,
    :provisional_green_IT,
    :provisional_energy_building,
    :final_energy_centers_efficiency,
    :final_measurement_reporting_and_verification,
    :final_building_water_efficiency,
    :final_events_carbon_neutrality,
    :final_products_ecolabeling,
    :final_green_IT,
    :final_energy_building,
    :provisional_energy_label_for_building_performance,
    :provisional_indoor_air_quality_certification,
    :provisional_indoor_environmental_quality_certification,
    :provisional_energy_label_for_wastewater_treatment_plant,
    :provisional_energy_label_for_leachate_treatment_plant,
    :provisional_healthy_building_label,
    :provisional_energy_label_for_industrial_application,
    :provisional_energy_label_for_infrastructure_projects,
    :final_energy_label_for_building_performance,
    :final_indoor_air_quality_certification,
    :final_indoor_environmental_quality_certification,
    :final_energy_label_for_wastewater_treatment_plant,
    :final_energy_label_for_leachate_treatment_plant,
    :final_healthy_building_label,
    :final_energy_label_for_industrial_application,
    :final_energy_label_for_infrastructure_projects
  ]

  PROVISIONAL_CERTIFICATES = [
    :provisional_energy_centers_efficiency,
    :provisional_measurement_reporting_and_verification,
    :provisional_building_water_efficiency,
    :provisional_events_carbon_neutrality,
    :provisional_products_ecolabeling,
    :provisional_green_IT,
    :provisional_energy_building,
    :provisional_energy_label_for_building_performance,
    :provisional_indoor_air_quality_certification,
    :provisional_indoor_environmental_quality_certification,
    :provisional_energy_label_for_wastewater_treatment_plant,
    :provisional_energy_label_for_leachate_treatment_plant,
    :provisional_healthy_building_label,
    :provisional_energy_label_for_industrial_application,
    :provisional_energy_label_for_infrastructure_projects
  ]
  PROVISIONAL_CERTIFICATES_VALUES = certification_types.select{ |k, v| v if k.include?("provisional_")}&.values

  FINAL_CERTIFICATES = [
    :final_energy_centers_efficiency,
    :final_measurement_reporting_and_verification,
    :final_building_water_efficiency,
    :final_events_carbon_neutrality,
    :final_products_ecolabeling,
    :final_green_IT,
    :final_energy_building,
    :final_energy_label_for_building_performance,
    :final_indoor_air_quality_certification,
    :final_indoor_environmental_quality_certification,
    :final_energy_label_for_wastewater_treatment_plant,
    :final_energy_label_for_leachate_treatment_plant,
    :final_healthy_building_label,
    :final_energy_label_for_industrial_application,
    :final_energy_label_for_infrastructure_projects
  ]
  FINAL_CERTIFICATES_VALUES = certification_types.select{ |k, v| v if k.include?("final_")}&.values

  has_many :certification_paths
  has_many :development_types, dependent: :destroy

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

  def energy_building?
    energy_building_type?
  end

  def energy_label_for_building_performance?
    energy_label_for_building_performance_type?
  end

  def indoor_air_quality_certification?
    indoor_air_quality_certification_type?
  end

  def indoor_environmental_quality_certification?
    indoor_environmental_quality_certification_type?
  end

  def energy_label_for_wastewater_treatment_plant?
    energy_label_for_wastewater_treatment_plant_type?
  end

  def energy_label_for_leachate_treatment_plant?
    energy_label_for_leachate_treatment_plant_type?
  end

  def healthy_building_label?
    healthy_building_label_type?
  end

  def energy_label_for_industrial_application?
    energy_label_for_industrial_application_type?
  end

  def energy_label_for_infrastructure_projects?
    energy_label_for_infrastructure_projects_type?
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
                              when "energy_building_type"
                                [Certificate.certification_types[:provisional_energy_building], Certificate.certification_types[:final_energy_building]]
                              when "energy_label_for_building_performance_type"
                                [Certificate.certification_types[:provisional_energy_label_for_building_performance], Certificate.certification_types[:final_energy_label_for_building_performance]]
                              when "indoor_air_quality_certification_type"
                                [Certificate.certification_types[:provisional_indoor_air_quality_certification], Certificate.certification_types[:final_indoor_air_quality_certification]]
                              when "indoor_environmental_quality_certification_type"
                                [Certificate.certification_types[:provisional_indoor_environmental_quality_certification], Certificate.certification_types[:final_indoor_environmental_quality_certification]]
                              when "energy_label_for_wastewater_treatment_plant_type"
                                [Certificate.certification_types[:provisional_energy_label_for_wastewater_treatment_plant], Certificate.certification_types[:final_energy_label_for_wastewater_treatment_plant]]
                              when "energy_label_for_leachate_treatment_plant_type"
                                [Certificate.certification_types[:provisional_energy_label_for_leachate_treatment_plant], Certificate.certification_types[:final_energy_label_for_leachate_treatment_plant]]
                              when "healthy_building_label_type"
                                [Certificate.certification_types[:provisional_healthy_building_label], Certificate.certification_types[:final_healthy_building_label]]
                              when "energy_label_for_industrial_application_type"
                                [Certificate.certification_types[:provisional_energy_label_for_industrial_application], Certificate.certification_types[:final_energy_label_for_industrial_application]]
                              when "energy_label_for_infrastructure_projects_type"
                                [Certificate.certification_types[:provisional_energy_label_for_infrastructure_projects], Certificate.certification_types[:final_energy_label_for_infrastructure_projects]]
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
