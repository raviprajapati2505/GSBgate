class Licence < ApplicationRecord
  enum applicability: { both: 1, star_rating: 2, check_list: 3 }

  validates :type, :display_name, :title, :description, :certificate_type, :applicability, :schemes, presence: true
  validates :certificate_type, inclusion: Certificate.certificate_types.values
end
