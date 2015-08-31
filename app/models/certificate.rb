class Certificate < ActiveRecord::Base
  enum certificate_type: [ :design_type, :construction_type, :operations_type ]
  enum assessment_stage: [ :design_stage, :construction_stage, :operations_stage ]

  has_many :certification_paths
  has_many :schemes

  def letter_of_conformance?
    design_type? and design_stage?
  end

  def final_design_certificate?
    design_type? and construction_stage?
  end

  def construction_certificate?
    construction_type? and construction_stage?
  end

  def operations_certificate?
    operations_type? and operations_stage?
  end

  scope :letter_of_conformance, -> {
    where(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:design_stage])
  }

  scope :final_design_certificate, -> {
    where(certificate_type: Certificate.certificate_types[:design_type], assessment_stage: Certificate.assessment_stages[:construction_stage])
  }

  scope :construction_certificate, -> {
    where(certificate_type: Certificate.certificate_types[:construction_type], assessment_stage: Certificate.assessment_stages[:construction_stage])
  }

  scope :operations_certificate, -> {
    where(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage])
  }

end
