module Offline
  class SchemeMixCriterion < ApplicationRecord
    belongs_to :offline_scheme_mix, class_name: 'Offline::SchemeMix', foreign_key: 'offline_scheme_mix_id', inverse_of: :offline_scheme_mix_criteria
  end
end