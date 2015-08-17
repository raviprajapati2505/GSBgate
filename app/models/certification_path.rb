class CertificationPath < ActiveRecord::Base
  belongs_to :project
  belongs_to :certificate
  has_many :scheme_mixes
  has_many :schemes, through: :scheme_mixes
  has_many :scheme_mix_criteria, through: :scheme_mixes
  has_many :scheme_mix_criteria_documents, through: :scheme_mix_criteria
  has_many :scheme_mix_criteria_requirement_data, through: :scheme_mix_criteria
  has_many :requirement_data, through: :scheme_mix_criteria_requirement_data

  accepts_nested_attributes_for :certificate

  enum status: [ :registered, :in_submission, :in_screening, :screened, :in_review, :reviewed, :in_verification, :certification_rejected, :awaiting_approval, :awaiting_signatures, :certified ]

  scope :with_all_criteria_completed, -> {
    where.not('exists(select smc.id from scheme_mix_criteria smc inner join scheme_mixes sm on sm.id = smc.scheme_mix_id where smc.status = 0 and sm.certification_path_id = certification_paths.id)')
  }

  scope :with_all_criteria_reviewed, -> {
    where.not('exists(select smc.id from scheme_mix_criteria smc inner join scheme_mixes sm on sm.id = smc.scheme_mix_id where (smc.status = 0 or smc.status = 1) and sm.certification_path_id = certification_paths.id)')
  }

  def has_fixed_scheme?
    certificate.schemes.count == 1
  end

  def total_weighted_targeted_score
    total = nil
    scheme_mixes.each do |sm|
      total ||= 0
      total += sm.weighted_targeted_score
    end
    total.nil? ? -1 : total
  end

  def total_weighted_submitted_score
    total = nil
    scheme_mixes.each do |sm|
      total ||= 0
      total += sm.weighted_submitted_score
    end
    total.nil? ? -1 : total
  end

  def total_weighted_achieved_score
    total = nil
    scheme_mixes.each do |sm|
      total ||= 0
      total += sm.weighted_achieved_score
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

  # Mirrors all the descendant structural data records of the Cerifi to user data records
  def create_descendant_records
    if self.scheme_mixes.any?
      raise('Scheme_mixes are already created')
    end

    # if multiple schemes, user should do the weighting
    if self.certificate.schemes.many?
      weight = 0
    else
      weight = 100
    end

    self.certificate.schemes.each do |scheme|
      SchemeMix.create(certification_path_id: self.id, scheme_id: scheme.id, weight: weight)
    end
  end
end
