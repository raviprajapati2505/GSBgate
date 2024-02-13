class ServiceProvider < User
  has_one :service_provider_detail, dependent: :destroy, inverse_of: :service_provider
  has_many :users, class_name: 'User', foreign_key: 'service_provider_id', dependent: :destroy

  accepts_nested_attributes_for :service_provider_detail

  def valid_service_provider_licences
    AccessLicence.none
  end

  def valid_service_provider_design_build_licences
    AccessLicence.none
  end

  def valid_service_provider_construction_management_licences
    AccessLicence.none
  end

  def valid_service_provider_operation_licences
    AccessLicence.none
  end

  def valid_service_provider_ecoleaf_licences
    AccessLicence.none
  end

  def valid_cgps
    AccessLicence.none
  end

  def valid_ceps
    AccessLicence.none
  end

  def valid_design_build_cgps
    AccessLicence.none
  end

  def valid_design_build_ceps
    AccessLicence.none
  end

  def valid_construction_management_cgps
    AccessLicence.none
  end

  def valid_construction_management_ceps
    AccessLicence.none
  end

  def valid_operation_cgps
    AccessLicence.none
  end

  def valid_operation_ceps
    AccessLicence.none
  end

  def valid_ecoleaf_cgps
    AccessLicence.none
  end

  def valid_ecoleaf_ceps
    AccessLicence.none
  end
end
