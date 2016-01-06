class Certificate < ActiveRecord::Base
  enum certificate_type: { design_type: 0, construction_type: 1, operations_type: 2 }
  enum assessment_stage: { design_stage: 0, construction_stage: 1, operations_stage: 2 }

  has_many :certification_paths
  has_many :schemes

  validates_inclusion_of :certificate_type, in: Certificate.certificate_types.keys
  validates_inclusion_of :assessment_stage, in: Certificate.assessment_stages.keys

  def letter_of_conformance?
    design_type? && design_stage?
  end

  def final_design_certificate?
    design_type? && construction_stage?
  end

  def construction_certificate?
    construction_type? && construction_stage?
  end

  def operations_certificate?
    operations_type? && operations_stage?
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

  def full_name
    self.name + ', ' + self.version
  end
end
