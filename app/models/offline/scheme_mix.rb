module Offline
  class SchemeMix < ApplicationRecord
    belongs_to :offline_certification_path, class_name: 'Offline::CertificationPath', foreign_key: 'offline_certification_path_id', inverse_of: :offline_scheme_mixes

    has_many :offline_scheme_mix_criteria, class_name: 'Offline::SchemeMixCriterion', foreign_key: 'offline_scheme_mix_id', inverse_of: :offline_scheme_mix, dependent: :destroy

    accepts_nested_attributes_for :offline_scheme_mix_criteria, allow_destroy: true
    
    validates :name, :weight, presence: true
  end
end