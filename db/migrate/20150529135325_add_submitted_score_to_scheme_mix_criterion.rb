class AddSubmittedScoreToSchemeMixCriterion < ActiveRecord::Migration[4.2]
  def change
    add_column :scheme_mix_criteria, :submitted_score, :integer
  end
end