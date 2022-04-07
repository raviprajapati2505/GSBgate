class CpLicence < Licence
  has_many :access_licences, as: :licensable, dependent: :destroy
  has_many :users, through: :access_licences, source: :userable, source_type: 'User'
end