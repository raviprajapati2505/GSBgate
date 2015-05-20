class Scheme < ActiveRecord::Base
  belongs_to :certificate
  has_many :scheme_mixes
  has_many :certification_paths, through: :scheme_mixes
  has_many :scheme_criteria

  def full_label
    "GSAS #{self.certificate.assessment_stage} Assessment v#{version}: #{label}"
  end

end
