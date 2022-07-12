module Offline
  class CertificatePath < ApplicationRecord

    belongs_to :offline_project, class_name: 'Offline::Project', foreign_key: 'offline_project_id', inverse_of: :offline_certificate_paths

    #has_many :offline_scheme_mixes, dependent: :destroy
    has_many :offline_scheme_mixes, class_name: 'Offline::SchemeMix', foreign_key: 'offline_certificate_path_id',inverse_of: :offline_certificate_path, dependent: :destroy
    
    accepts_nested_attributes_for :offline_scheme_mixes

    validates :name, :version, :development_type, :status, :rating, presence: true

    enum version: { "v2.0" => 1, "v1.0" => 2 }
    enum rating: { "1 Stars" => 1, "2 Stars" => 2, "3 Stars" => 3, "4 Stars" => 4, "5 Stars" => 5, "6 Stars" => 6 }
  end
end