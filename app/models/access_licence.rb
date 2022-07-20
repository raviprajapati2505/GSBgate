class AccessLicence < ApplicationRecord
  belongs_to :licence
  belongs_to :user

  # Validation
  validates :expiry_date, presence: true

  default_scope { joins(:licence).order("licences.display_weight") }

  scope :user_access_licences, -> (user_id) {
    where(user_id: user_id)
  }

  scope :with_certificate_type, -> (certificate_type) {
    joins(:licence).where("licences.certificate_type = :certificate_type", certificate_type: certificate_type)
  }

  def licence_display_name
    licence&.display_name
  end

  def licence_applicable_for
    case licence.applicability
    when 'both'
      "Star Rating & Checklist Compliance"
    when 'star_rating'
      "Star Rating"
    when 'check_list'
      "Checklist Compliance"
    else
      ""
    end
  end

  def licence_schemes
    licence&.schemes&.sort
  end

  def licence_description
    licence&.description
  end

  def formatted_expiry_date
    expiry_date&.strftime('%d %B, %Y')
  end
end
