class AccessLicence < ApplicationRecord
  belongs_to :licence
  belongs_to :userable, polymorphic: true

  # Validation
  validates :expiry_date, presence: true
  validates :licence_id, uniqueness: { scope: [:userable_id] }

  scope :userable_access_licences, -> (user_id) {
    where(userable_id: user_id)
  }

  def licence_display_name
    licence&.display_name
  end

  def licence_applicable_for
    case licence.applicability
    when 'both'
      "Star Rating Based Certificate & Checklist Based Certificate"
    when 'star_rating'
      "Star Rating Based Certificate"
    when 'check_list'
      "Checklist Based Certificate"
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
