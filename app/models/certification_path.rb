class CertificationPath < AuditableRecord
  belongs_to :project
  belongs_to :certificate
  has_many :scheme_mixes
  has_many :schemes, through: :scheme_mixes
  has_many :scheme_mix_criteria, through: :scheme_mixes
  has_many :scheme_mix_criteria_documents, through: :scheme_mix_criteria
  has_many :scheme_mix_criteria_requirement_data, through: :scheme_mix_criteria
  has_many :requirement_data, through: :scheme_mix_criteria_requirement_data

  accepts_nested_attributes_for :certificate
  accepts_nested_attributes_for :scheme_mixes

  enum development_type: { not_applicable: 0, single_use: 1, mixed_use: 2, mixed_development: 3, mixed_development_in_stages: 4 }
  enum status: { awaiting_activation: 0, awaiting_submission: 1, awaiting_screening: 2, awaiting_submission_after_screening: 3, awaiting_pcr_payment: 4, awaiting_submission_after_pcr: 5, awaiting_verification: 6, awaiting_approval_or_appeal: 7, awaiting_appeal_payment: 8, awaiting_submission_after_appeal: 9, awaiting_verification_after_appeal: 10, awaiting_approval_after_appeal: 11, awaiting_management_approvals: 12, certified: 13 }

  validates :project, :presence => true
  validates :certificate, :presence => true
  validates_inclusion_of :development_type, in: CertificationPath.development_types.keys
  validates_inclusion_of :status, in: CertificationPath.statuses.keys

  def name
    self.certificate.name
  end

  def has_fixed_scheme?
    certificate.schemes.count == 1
  end

  def total_weighted_targeted_score
    total = nil
    scheme_mixes.each do |sm|
      total ||= 0
      total += sm.total_weighted_targeted_score
    end
    total.nil? ? -1 : total
  end

  def total_weighted_submitted_score
    total = nil
    scheme_mixes.each do |sm|
      total ||= 0
      total += sm.total_weighted_submitted_score
    end
    total.nil? ? -1 : total
  end

  def total_weighted_achieved_score
    total = nil
    scheme_mixes.each do |sm|
      total ||= 0
      total += sm.total_weighted_achieved_score
    end
    total.nil? ? -1 : total
  end

  def star_rating_for_score(score)
    if score >= 0 && score <= 0.5
      return 1
    elsif score > 0.5 && score <= 1
      return 2
    elsif score > 1 && score <= 1.5
      return 3
    elsif score > 1.5 && score <= 2
      return 4
    elsif score > 2 && score <= 2.5
      return 5
    elsif score > 2.5 && score <= 3
      return 6
    else
      return -1
    end
  end
end
