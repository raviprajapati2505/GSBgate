class Certificate < ApplicationRecord
  enum certificate_type: { design_type: 3, construction_type: 1, operations_type: 2 }
  enum assessment_stage: { design_stage: 3, construction_stage: 1, operations_stage: 2 }

  enum certification_type: { letter_of_conformance: 10, final_design_certificate: 20, construction_certificate: 30, construction_certificate_stage1: 31, construction_certificate_stage2: 32, construction_certificate_stage3: 33, operations_certificate: 40 }

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

  def operations?
    name.include?('Operations')
  end

  def operations_2019?
    operations_type? && gsas_version == '2019'
  end

  def design_and_build?
    design_type?
  end

  def full_name
    self.name
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
      'GSAS Design Certificate_LOC'
      # t('letter_of_conformance', scope: '.activerecord.attributes.certificate.certificate_types.stage_titles')
    when "Final Design Certificate"
      'GSAS Design & Build Certificate_CDA'
      # t('final_design_certificate', scope: '.activerecord.attributes.certificate.certificate_types.stage_titles')
    else
      full_name
    end
  end
end
