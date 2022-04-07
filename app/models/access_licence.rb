class AccessLicence < ApplicationRecord
  belongs_to :licensable, polymorphic: true
  belongs_to :userable, polymorphic: true
end
