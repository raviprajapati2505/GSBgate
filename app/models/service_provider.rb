class ServiceProvider < User
  has_many :users, class_name: 'User', foreign_key: 'service_provider_id', dependent: :destroy

  def valid_service_provider_licences
    access_licences.joins(:licence).where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'ServiceProviderLicence'", current_date: Date.today)
  end

  def valid_cgps
    users.joins(access_licences: :licence).where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CgpLicence'", current_date: Date.today)
  end

  def valid_ceps
    users.joins(access_licences: :licence).where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CepLicence'", current_date: Date.today)
  end
end
