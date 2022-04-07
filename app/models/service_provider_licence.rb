class ServiceProviderLicence < Licence
  has_many :access_licences, as: :licensable, dependent: :destroy
  has_many :service_providers, through: :access_licences, source: :userable, source_type: 'ServiceProvider'
end