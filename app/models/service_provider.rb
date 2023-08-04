class ServiceProvider < User

  has_one :service_provider_detail, dependent: :destroy, inverse_of: :service_provider
  has_many :users, class_name: 'User', foreign_key: 'service_provider_id', dependent: :destroy

  accepts_nested_attributes_for :service_provider_detail

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

  def valid_service_provider_ecoleaf_licences
    access_licences.joins(:licence).where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'ServiceProviderLicence' AND licences.certificate_type = :certificate_type", current_date: Date.today, certificate_type: Certificate.certificate_types[:ecoleaf_type]) || AccessLicence.none
  end

  def valid_cgps
    users.joins('INNER JOIN access_licences on access_licences.user_id = users.id').joins('INNER JOIN licences on licences.id = access_licences.licence_id').where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CgpLicence' AND users.active = true", current_date: Date.today) || AccessLicence.none
  end

  def valid_ceps
    users.joins('INNER JOIN access_licences on access_licences.user_id = users.id').joins('INNER JOIN licences on licences.id = access_licences.licence_id').where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CepLicence' AND users.active = true", current_date: Date.today) || AccessLicence.none
  end

  def valid_design_build_cgps
    users.joins('INNER JOIN access_licences on access_licences.user_id = users.id').joins('INNER JOIN licences on licences.id = access_licences.licence_id').where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CgpLicence' AND licences.certificate_type = :certificate_type AND users.active = true", current_date: Date.today, certificate_type: Certificate.certificate_types[:design_type]).references(:access_licences).references(:licences) || AccessLicence.none
  end

  def valid_design_build_ceps
    users.joins('INNER JOIN access_licences on access_licences.user_id = users.id').joins('INNER JOIN licences on licences.id = access_licences.licence_id').where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CepLicence' AND licences.certificate_type = :certificate_type AND users.active = true", current_date: Date.today, certificate_type: Certificate.certificate_types[:design_type]) || AccessLicence.none
  end

  def valid_construction_management_cgps
    users.joins('INNER JOIN access_licences on access_licences.user_id = users.id').joins('INNER JOIN licences on licences.id = access_licences.licence_id').where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CgpLicence' AND licences.certificate_type = :certificate_type AND users.active = true", current_date: Date.today, certificate_type: Certificate.certificate_types[:construction_type]) || AccessLicence.none
  end

  def valid_construction_management_ceps
    users.joins('INNER JOIN access_licences on access_licences.user_id = users.id').joins('INNER JOIN licences on licences.id = access_licences.licence_id').where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CepLicence' AND licences.certificate_type = :certificate_type AND users.active = true", current_date: Date.today, certificate_type: Certificate.certificate_types[:construction_type]) || AccessLicence.none
  end

  def valid_operation_cgps
    users.joins('INNER JOIN access_licences on access_licences.user_id = users.id').joins('INNER JOIN licences on licences.id = access_licences.licence_id').where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CgpLicence' AND licences.certificate_type = :certificate_type AND users.active = true", current_date: Date.today, certificate_type: Certificate.certificate_types[:operations_type]) || AccessLicence.none
  end

  def valid_operation_ceps
    users.joins('INNER JOIN access_licences on access_licences.user_id = users.id').joins('INNER JOIN licences on licences.id = access_licences.licence_id').where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CepLicence' AND licences.certificate_type = :certificate_type AND users.active = true", current_date: Date.today, certificate_type: Certificate.certificate_types[:operations_type]) || AccessLicence.none
  end

  def valid_ecoleaf_cgps
    users.joins(access_licences: :licence).where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CgpLicence' AND licences.certificate_type = :certificate_type AND users.active = true", current_date: Date.today, certificate_type: Certificate.certificate_types[:ecoleaf_type]) || AccessLicence.none
  end

  def valid_ecoleaf_ceps
    users.joins(access_licences: :licence).where("DATE(access_licences.expiry_date) > :current_date AND licences.licence_type = 'CepLicence' AND licences.certificate_type = :certificate_type AND users.active = true", current_date: Date.today, certificate_type: Certificate.certificate_types[:ecoleaf_type]) || AccessLicence.none
  end
end
