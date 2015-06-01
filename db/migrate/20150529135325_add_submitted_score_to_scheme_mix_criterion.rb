class AddSubmittedScoreToSchemeMixCriterion < ActiveRecord::Migration
  def change
    add_column :scheme_mix_criteria, :submitted_score, :integer
  end
end