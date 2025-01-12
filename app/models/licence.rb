class Licence < ApplicationRecord
  enum applicability: [:check_list]

  has_many :access_licences, dependent: :destroy
  has_many :users, through: :access_licences
  has_many :cp_users, -> { where(users: { type: 'User' }) }, class_name: 'User', through: :access_licences, source: :user
  # has_many :service_providers, -> { where(users: { type: 'ServiceProvider' }) }, class_name: 'User', through: :access_licences, source: :user

  validates :licence_type, :display_name, :title, :description, :certificate_type, presence: true
  validates :licence_type, inclusion: ['CgpLicence', 'CepLicence']
  validates :certificate_type, inclusion: Certificate.certificate_types.values

  # scope :with_service_provider_licences, -> {
  #   where(licence_type: 'ServiceProviderLicence').order(:display_weight)
  # }

  scope :with_cp_licences, -> {
    where.not(licence_type: 'ServiceProviderLicence').order(:display_weight)
  }

  scope :with_cgp_licences, -> {
    where(licence_type: 'CgpLicence').order(:display_weight)
  }

  scope :with_cep_licences, -> {
    where(licence_type: 'CepLicence').order(:display_weight)
  }
end
