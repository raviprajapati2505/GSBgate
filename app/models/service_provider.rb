class ServiceProvider < User
  has_many :users, class_name: 'User', foreign_key: 'service_provider_id', dependent: :destroy

  def valid_service_provider_licences
    access_licences.joins(:licence).where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'ServiceProviderLicence'", current_date: Date.today) || AccessLicence.none
  end

  def valid_service_provider_design_build_licences
    access_licences.joins(:licence).where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'ServiceProviderLicence' AND licences.certificate_type = :certificate_type", current_date: Date.today, certificate_type: Certificate.certificate_types[:design_type]) || AccessLicence.none
  end

  def valid_service_provider_construction_management_licences
    access_licences.joins(:licence).where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'ServiceProviderLicence' AND licences.certificate_type = :certificate_type", current_date: Date.today, certificate_type: Certificate.certificate_types[:construction_type]) || AccessLicence.none
  end

  def valid_service_provider_operation_licences
    access_licences.joins(:licence).where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'ServiceProviderLicence' AND licences.certificate_type = :certificate_type", current_date: Date.today, certificate_type: Certificate.certificate_types[:operations_type]) || AccessLicence.none
  end

  def valid_cgps
    users.joins(access_licences: :licence).where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CgpLicence'", current_date: Date.today) || AccessLicence.none
  end

  def valid_ceps
    users.joins(access_licences: :licence).where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CepLicence'", current_date: Date.today) || AccessLicence.none
  end

  def valid_design_build_cgps
    users.joins(access_licences: :licence).where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CgpLicence' AND licences.certificate_type = :certificate_type", current_date: Date.today, certificate_type: Certificate.certificate_types[:design_type]) || AccessLicence.none
  end

  def valid_design_build_ceps
    users.joins(access_licences: :licence).where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CepLicence' AND licences.certificate_type = :certificate_type", current_date: Date.today, certificate_type: Certificate.certificate_types[:design_type]) || AccessLicence.none
  end

  def valid_construction_management_cgps
    users.joins(access_licences: :licence).where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CgpLicence' AND licences.certificate_type = :certificate_type", current_date: Date.today, certificate_type: Certificate.certificate_types[:construction_type]) || AccessLicence.none
  end

  def valid_construction_management_ceps
    users.joins(access_licences: :licence).where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CepLicence' AND licences.certificate_type = :certificate_type", current_date: Date.today, certificate_type: Certificate.certificate_types[:construction_type]) || AccessLicence.none
  end

  def valid_operation_cgps
    users.joins(access_licences: :licence).where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CgpLicence' AND licences.certificate_type = :certificate_type", current_date: Date.today, certificate_type: Certificate.certificate_types[:operations_type]) || AccessLicence.none
  end

  def valid_operation_ceps
    users.joins(access_licences: :licence).where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CepLicence' AND licences.certificate_type = :certificate_type", current_date: Date.today, certificate_type: Certificate.certificate_types[:operations_type]) || AccessLicence.none
  end
end
