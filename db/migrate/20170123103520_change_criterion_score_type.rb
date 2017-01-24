class ChangeCriterionScoreType < ActiveRecord::Migration
  def change
    change_column :scheme_criteria, :minimum_score, :decimal, precision: 3, scale: 1
    change_column :scheme_criteria, :maximum_score, :decimal, precision: 3, scale: 1
    change_column :scheme_criteria, :minimum_valid_score, :decimal, precision: 3, scale: 1

    change_column :scheme_mix_criteria, :targeted_score, :decimal, precision: 3, scale: 1
    change_column :scheme_mix_criteria, :submitted_score, :decimal, precision: 3, scale: 1
    change_column :scheme_mix_criteria, :achieved_score, :decimal, precision: 3, scale: 1

    SchemeCriterion.where(scheme_category_id: [52,53,54,55,56]).update_all('maximum_score = weight, scores = null')

    SchemeCriterion.where.not(scheme_category_id: [52,53,54,55,56]).each do |sc|
      new_scores = []
      sc.scores.each do |score|
        new_scores.push([score, Float(score)])
      end
      sc.scores = new_scores
      sc.save!
    end
  end
end
