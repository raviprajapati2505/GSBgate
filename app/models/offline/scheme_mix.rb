module Offline
  class SchemeMix < ApplicationRecord
    belongs_to :offline_certificate_paths, class_name: 'Offline::CertificatePath', foreign_key: 'offline_certificate_path_id', inverse_of: :offline_scheme_mixes
    
    validates :name, presence: true
    
    #enum name: { "Sports" => 1, "Mosques" => 2, "Education" => 3,"Commercial" => 4, "Mixed Use" => 5, "Residential" => 6, "Hospitality" => 7, "Healthcare" => 8, "Light Industry" => 9, "Parks" => 10 }
  end
end