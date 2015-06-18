class CriteriaStatusLog < ActiveRecord::Base
  belongs_to :scheme_mix_criterion
  belongs_to :user

  # validates :old_status, inclusion: SchemeMixCriterion.statuses.keys
  # validates :new_status, inclusion: SchemeMixCriterion.statuses.keys

end