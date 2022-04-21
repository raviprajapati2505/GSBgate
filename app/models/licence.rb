class Licence < ApplicationRecord
  enum applicability: { both: 3, star_rating: 1, check_list: 2 }

  has_many :access_licences, dependent: :destroy
  has_many :users, through: :access_licences
  has_many :cp_users, -> { where(users: { type: 'User' }) }, class_name: 'User', through: :access_licences, source: :user
  has_many :service_providers, -> { where(users: { type: 'ServiceProvider' }) }, class_name: 'User', through: :access_licences, source: :user

  validates :licence_type, :display_name, :title, :description, :certificate_type, :applicability, presence: true
  validates :licence_type, inclusion: ['ServiceProviderLicence', 'CgpLicence', 'CepLicence']
  validates :certificate_type, inclusion: Certificate.certificate_types.values

  scope :with_service_provider_licences, -> {
    where(licence_type: 'ServiceProviderLicence')
  }

  scope :with_cgp_licences, -> {
    where(licence_type: 'CgpLicence')
  }

  scope :with_cep_licences, -> {
    where(licence_type: 'CepLicence')
  }
end
