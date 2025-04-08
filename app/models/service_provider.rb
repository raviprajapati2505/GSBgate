class ServiceProvider < User
  has_one :service_provider_detail, dependent: :destroy, inverse_of: :service_provider
  has_many :users, class_name: 'User', foreign_key: 'service_provider_id', dependent: :destroy

  accepts_nested_attributes_for :service_provider_detail

  def valid_service_provider_licences
    access_licences
      .joins(:licence)
      .where(
        "DATE(access_licences.expiry_date) > :current_date 
        AND licences.licence_type = 'ServiceProviderLicence'", 
        current_date: Date.today
      ) || AccessLicence.none
  end

  def valid_cgps
    users
      .joins("INNER JOIN access_licences on access_licences.user_id = users.id")
      .joins("INNER JOIN licences on licences.id = access_licences.licence_id")
      .where(
        "DATE(access_licences.expiry_date) > :current_date 
        AND licences.licence_type = 'CgpLicence' 
        AND users.active = true", 
        current_date: Date.today
      ) || AccessLicence.none
  end

  def valid_ceps
    users
      .joins("INNER JOIN access_licences on access_licences.user_id = users.id")
      .joins("INNER JOIN licences on licences.id = access_licences.licence_id")
      .where(
        "DATE(access_licences.expiry_date) > :current_date 
        AND licences.licence_type = 'CepLicence' 
        AND users.active = true", 
        current_date: Date.today
      ) || AccessLicence.none
  end

  Certificate::CERTIFICATE_TYPES.each do |cert_type|
    define_method("valid_service_provider_#{cert_type}_licences") do
      access_licences
        .valid_service_provider_licences_with_type(Certificate.certificate_types[:"#{cert_type}_type"]) || AccessLicence.none
    end
  
    define_method("valid_#{cert_type}_cgps") do
      users
        .valid_cgps_with_type(Certificate.certificate_types[:"#{cert_type}_type"]) || AccessLicence.none
    end
  
    define_method("valid_#{cert_type}_ceps") do
      users
        .valid_ceps_with_type(Certificate.certificate_types[:"#{cert_type}_type"]) || AccessLicence.none
    end
  end  
end
