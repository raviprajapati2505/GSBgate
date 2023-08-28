class Certificate < ApplicationRecord
  enum certificate_type: { design_type: 3, construction_type: 1, operations_type: 2, ecoleaf_type: 4 }
  enum assessment_stage: { design_stage: 3, construction_stage: 1, operations_stage: 2, ecoleaf_stage: 4  }

  enum certification_type: { letter_of_conformance: 10, final_design_certificate: 20, construction_certificate: 30, construction_certificate_stage1: 31, construction_certificate_stage2: 32, construction_certificate_stage3: 33, operations_certificate: 40, ecoleaf_provisional_certificate: 45, ecoleaf_certificate: 50 }

  has_many :certification_paths
  has_many :development_types

  validates_inclusion_of :certificate_type, in: Certificate.certificate_types.keys
  validates_inclusion_of :assessment_stage, in: Certificate.assessment_stages.keys
  validates_inclusion_of :certification_type, in: Certificate.certification_types.keys

  scope :with_gsas_version, ->(gsas_version) {
    where(gsas_version: gsas_version)
  }

  scope :with_certification_type, ->(certification_type) {
    where(certification_type: certification_type)
  }

  def construction_issue_1?
    construction_type? && gsas_version == 'v2.1 Issue 1.0'
  end

  def construction_issue_3?
    construction_type? && gsas_version == 'v2.1 Issue 3.0'
  end

  def construction_2019?
    construction_type? && gsas_version == '2019'
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
    operations_type? && gsas_version == '2019'
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
                              when "GSAS-D&B"
                                [Certificate.certification_types[:letter_of_conformance], Certificate.certification_types[:final_design_certificate]]
                              when "GSAS-CM"
                                [Certificate.certification_types[:construction_certificate], Certificate.certification_types[:construction_certificate_stage1], Certificate.certification_types[:construction_certificate_stage2], Certificate.certification_types[:construction_certificate_stage3]]
                              when "GSAS-OP"
                                [Certificate.certification_types[:operations_certificate]]
                              when "GSAS-EcoLeaf"
                                [Certificate.certification_types[:ecoleaf_provisional_certificate], Certificate.certification_types[:ecoleaf_certificate]]
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
                                      when "GSAS Construction Management Certificate"
                                        Certificate.certification_types[:construction_certificate]
                                      when "Stage 1: Foundation"
                                        Certificate.certification_types[:construction_certificate_stage1]
                                      when "Stage 2: Substructure & Superstructure"
                                        Certificate.certification_types[:construction_certificate_stage2]
                                      when "Stage 3: Finishing"
                                        Certificate.certification_types[:construction_certificate_stage3]
                                      when "GSAS Operations Certificate"
                                        Certificate.certification_types[:operations_certificate]
                                      when "Stage 1: Provisional Certificate"
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
    case only_name
    when "Letter of Conformance", "Final Design Certificate"
      I18n.t('activerecord.attributes.certificate.certificate_types.certificate_titles.design_and_build')
    when "GSAS-CM", "Construction Certificate"
      I18n.t('activerecord.attributes.certificate.certificate_types.certificate_titles.construction_certificate')
    when "Operations Certificate"
      I18n.t('activerecord.attributes.certificate.certificate_types.certificate_titles.operations_certificate')
    when "GSAS-EcoLeaf"
      I18n.t('activerecord.attributes.certificate.certificate_types.certificate_titles.gsas_ecoleaf')
    end
  end

  def report_certification_name
    case only_name
    when "Letter of Conformance", "Final Design Certificate"
      "GSAS Design & Build (#{only_certification_name})"
    when "GSAS-CM", "Construction Certificate"
      "GSAS Construction Management (#{only_certification_name})"
    when "Operations Certificate"
      "GSAS Operation (#{only_certification_name})"
    when "GSAS-EcoLeaf"
      only_certification_name
    end
  end

  def only_name
    name&.split(',')[0]
  end

  def only_version
    gsas_version
  end

  def stage_title
    case only_name
    when "Letter of Conformance"
      I18n.t('activerecord.attributes.certificate.certificate_types.stage_titles.letter_of_conformance')
    when "Final Design Certificate"
      I18n.t('activerecord.attributes.certificate.certificate_types.stage_titles.final_design_certificate')
    else
      I18n.t("activerecord.attributes.certificate.certificate_types.stage_titles.#{certification_type}")
    end
  end

  def team_title
    I18n.t("activerecord.attributes.project.team_titles.#{certification_type}")
  end
end
