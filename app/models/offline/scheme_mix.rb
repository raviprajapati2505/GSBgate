module Offline
  class SchemeMix < ApplicationRecord
    belongs_to :offline_certificate_path, class_name: 'Offline::CertificatePath', foreign_key: 'offline_certificate_path_id', inverse_of: :offline_scheme_mixes

    has_many :offline_scheme_mix_criteria, class_name: 'Offline::SchemeMixCriterion', foreign_key: 'offline_scheme_mix_id', inverse_of: :offline_scheme_mix, dependent: :destroy

    accepts_nested_attributes_for :offline_scheme_mix_criteria
    
    validates :name, presence: true
  end
end