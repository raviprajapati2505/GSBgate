class AddMainSchemeMixCriterionToSchemeMixCriterion < ActiveRecord::Migration[4.2]
  def change
    add_reference :scheme_mix_criteria, :main_scheme_mix_criterion, references: :scheme_mix_criteria, index: true
  end
end
