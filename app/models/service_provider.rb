class ServiceProvider < User
  has_many :users, class_name: 'User', foreign_key: 'service_provider_id', dependent: :destroy
  has_many :access_licences, as: :userable, dependent: :destroy
  has_many :service_provider_licences, -> { where(licence_type: 'ServiceProviderLicence') }, class_name: 'Licence', through: :access_licences, source: :licensable
end
