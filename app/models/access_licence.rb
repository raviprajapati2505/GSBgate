class AccessLicence < ApplicationRecord
  belongs_to :licence
  belongs_to :userable, polymorphic: true

  scope :userable_access_licences, -> (user_id) {
    where(userable_id: user_id)
  }
end
