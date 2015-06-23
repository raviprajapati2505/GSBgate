class CertificationPath < ActiveRecord::Base
  belongs_to :project
  belongs_to :certificate
  has_many :scheme_mixes
  has_many :schemes, through: :scheme_mixes

  accepts_nested_attributes_for :certificate

  enum status: [ :registered, :preassessment ]

  def has_fixed_scheme?
    certificate.schemes.count == 1
  end

  def total_weighted_targeted_score
    scheme_mixes.joins(:scheme_mix_criteria).joins('INNER JOIN scheme_criteria ON scheme_criteria.id = scheme_mix_criteria.scheme_criterion_id').sum('scheme_mix_criteria.targeted_score * scheme_criteria.weight / 100 * scheme_mixes.weight / 100')
  end

  def total_weighted_submitted_score
    scheme_mixes.joins(:scheme_mix_criteria).joins('INNER JOIN scheme_criteria ON scheme_criteria.id = scheme_mix_criteria.scheme_criterion_id').sum('scheme_mix_criteria.submitted_score * scheme_criteria.weight / 100 * scheme_mixes.weight / 100')
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
