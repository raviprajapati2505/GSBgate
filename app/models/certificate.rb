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

  # def letter_of_conformance?
  #   design_type? && design_stage?
  # end
  #
  # def final_design_certificate?
  #   design_type? && construction_stage?
  # end
  #
  # def construction_certificate?
  #   construction_type? && construction_stage?
  # end
  #
  # def operations_certificate?
  #   operations_type? && operations_stage?
  # end
  #
  # scope :letter_of_conformance, -> {
  #   where(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:design_stage])
  # }
  #
  # scope :final_design_certificate, -> {
  #   where(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:construction_stage])
  # }
  #
  # scope :construction_certificate, -> {
  #   where(certificate_type: Certificate.certificate_types[:construction_type], assessment_stage: Certificate.assessment_stages[:construction_stage])
  # }
  #
  # scope :operations_certificate, -> {
  #   where(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage])
  # }

  def full_name
    self.name
  end
end
