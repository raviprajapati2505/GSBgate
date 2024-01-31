class Certificate < ApplicationRecord
  enum certificate_type: [ 
    :energy_centers_efficiency_type,
    :building_energy_efficiency_type,
    :healthy_buildings_type,
    :indoor_air_quality_type,
    :measurement_reporting_and_verification_type,
    :building_water_efficiency_type,
    :events_carbon_neutrality_type,
    :products_ecolabeling_type
  ]

  enum assessment_stage: [ 
    :energy_centers_efficiency_stage,
    :building_energy_efficiency_stage,
    :healthy_buildings_stage,
    :indoor_air_quality_stage,
    :measurement_reporting_and_verification_stage,
    :building_water_efficiency_stage,
    :events_carbon_neutrality_stage,
    :products_ecolabeling_stage
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
    :final_energy_centers_efficiency,
    :final_building_energy_efficiency,
    :final_Healthy_buildings,
    :final_indoor_air_quality,
    :final_measurement_reporting_and_verification,
    :final_building_water_efficiency,
    :final_events_carbon_neutrality,
    :final_products_ecolabeling
  ]

  PROVISIONAL_CERTIFICATES = [
    :provisional_energy_centers_efficiency,
    :provisional_building_energy_efficiency,
    :provisional_healthy_buildings,
    :provisional_indoor_air_quality,
    :provisional_measurement_reporting_and_verification,
    :provisional_building_water_efficiency,
    :provisional_events_carbon_neutrality,
    :provisional_products_ecolabeling
  ]

  FINAL_CERTIFICATES = [
    :final_energy_centers_efficiency,
    :final_building_energy_efficiency,
    :final_Healthy_buildings,
    :final_indoor_air_quality,
    :final_measurement_reporting_and_verification,
    :final_building_water_efficiency,
    :final_events_carbon_neutrality,
    :final_products_ecolabeling
  ]

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

  def construction_issue_1?
    construction_type? && gsb_version == 'v2.1 Issue 1.0'
  end

  def construction_issue_3?
    construction_type? && gsb_version == 'v2.1 Issue 3.0'
  end

  def construction_2019?
    construction_type? && gsb_version == '2019'
  end

  def final_construction?
    construction_type? && certification_type == 'construction_certificate'
  end

  def construction?
    certificate_type? && certificate_type == 'construction_type'
  end

  def operations?
    name.include?('Operations')
  end

  def operations_2019?
    operations_type? && gsb_version == '2019'
  end

  def design_and_build?
    design_type?
  end

  def ecoleaf?
    ecoleaf_type?
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
                              when "Energy Centers Efficiency"
                                [Certificate.certification_types[:provisional_energy_centers_efficiency], Certificate.certification_types[:final_energy_centers_efficiency]]
                              when "Building Energy Efficiency"
                                [Certificate.certification_types[:provisional_building_energy_efficiency], Certificate.certification_types[:final_building_energy_efficiency]]
                              when "Healthy Buildings"
                                [Certificate.certification_types[:provisional_healthy_buildings], Certificate.certification_types[:final_Healthy_buildings]]
                              when "Indoor Air Quality"
                                [Certificate.certification_types[:provisional_indoor_air_quality], Certificate.certification_types[:final_indoor_air_quality]]
                              when "Measurement, Reporting And Verification (MRV)"
                                [Certificate.certification_types[:provisional_measurement_reporting_and_verification], Certificate.certification_types[:final_measurement_reporting_and_verification]]
                              when "Buildings Water Efficiency"
                                [Certificate.certification_types[:provisional_building_water_efficiency], Certificate.certification_types[:final_building_water_efficiency]]
                              when "Events Carbon Neutrality"
                                [Certificate.certification_types[:provisional_events_carbon_neutrality], Certificate.certification_types[:final_events_carbon_neutrality]]
                              when "Products Ecolabeling"
                                [Certificate.certification_types[:provisional_products_ecolabeling], Certificate.certification_types[:final_products_ecolabeling]]
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
                                      when "Stage 1: LOC, Design Certificate", "Stage 1: LOC Design Certificate"
                                        Certificate.certification_types[:letter_of_conformance]
                                      when "Stage 2: CDA, Design & Build Certificate", "Stage 2: CDA Design & Build Certificate"
                                        Certificate.certification_types[:final_design_certificate]
                                      when "GSB Construction Management Certificate"
                                        Certificate.certification_types[:construction_certificate]
                                      when "Stage 1: Foundation"
                                        Certificate.certification_types[:construction_certificate_stage1]
                                      when "Stage 2: Substructure & Superstructure"
                                        Certificate.certification_types[:construction_certificate_stage2]
                                      when "Stage 3: Finishing"
                                        Certificate.certification_types[:construction_certificate_stage3]
                                      when "GSB Operations Certificate"
                                        Certificate.certification_types[:operations_certificate]
                                      when "EcoLeaf Provisional Certificate"
                                        Certificate.certification_types[:ecoleaf_provisional_certificate]
                                      when "Stage 2: EcoLeaf Certificate"
                                        Certificate.certification_types[:ecoleaf_certificate]
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
