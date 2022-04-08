class Licence < ApplicationRecord
  enum applicability: { both: 1, star_rating: 2, check_list: 3 }

  has_many :access_licences, dependent: :destroy
  has_many :users, through: :access_licences, source: :userable, source_type: 'User'
  has_many :service_providers, class_name: 'ServiceProvider', through: :access_licences, source: :userable, source_type: 'ServiceProvider'

  validates :licence_type, :display_name, :title, :description, :certificate_type, :time_period, :applicability, presence: true
  validates :licence_type, inclusion: ['ServiceProviderLicence', 'CpLicence']
  validates :certificate_type, inclusion: Certificate.certificate_types.values

  scope :with_service_provider_licences, -> {
    where(licence_type: 'ServiceProviderLicence')
  }

  scope :with_cp_licences, -> {
    where(licence_type: 'CpLicence')
  }
end
