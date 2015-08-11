class RenameScoreFieldsSchemeMixCriteria < ActiveRecord::Migration
  def change
    rename_column :scheme_mix_criteria, :targeted_score, :targeted_score_a
    rename_column :scheme_mix_criteria, :submitted_score, :submitted_score_a
    rename_column :scheme_mix_criteria, :achieved_score, :achieved_score_a
  end
end
