class AddScoreFieldsToSchemeMixCriteria < ActiveRecord::Migration[4.2]
  def change
    add_column :scheme_mix_criteria, :targeted_score_b, :integer
    add_column :scheme_mix_criteria, :submitted_score_b, :integer
    add_column :scheme_mix_criteria, :achieved_score_b, :integer
  end
end
