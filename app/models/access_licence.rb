class AccessLicence < ApplicationRecord
  include DatePlucker
  belongs_to :licence
  belongs_to :user

  # Validation
  validates :expiry_date, presence: true
  validates :user_id, uniqueness: { scope: :licence_id }

  mount_uploader :licence_file

  default_scope { joins(:licence).order("licences.display_weight") }

  scope :user_access_licences, -> (user_id) {
    where(user_id: user_id)
  }
  
  scope :with_certificate_type, -> (certificate_type) {
    joins(:licence).where("licences.certificate_type = :certificate_type", certificate_type: certificate_type)
  }

  scope :user_overdue_access_licences, -> (user_id) {
    where(user_id: user_id).where("expiry_date < :today", today: Date.today)
  }

  scope :users_of_service_provider, -> (current_user, certificate_type) {
    user_ids = []
    if User.is_service_provider(current_user)
      joins(:licence).where("licences.certificate_type = :certificate_type", certificate_type: certificate_type).where("user_id IN (:ids)", ids: current_user.users.ids)
    else
      joins(:licence).where("licences.certificate_type = :certificate_type", certificate_type: certificate_type).where("user_id IN (:ids)", ids: [])
    end
  }

  scope :valid_service_provider_licences_with_type, -> (certificate_type) {
      joins(:licence)
      .where(
        "DATE(access_licences.expiry_date) > :current_date 
        AND licences.licence_type = 'ServiceProviderLicence' 
        AND licences.certificate_type = :certificate_type", 
        current_date: Date.today, 
        certificate_type: certificate_type
      )
  }

  def licence_display_name
    licence&.display_name
  end

  def licence_applicable_for
    case licence.applicability
    when 'check_list'
      "Checklist Assessment"
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
