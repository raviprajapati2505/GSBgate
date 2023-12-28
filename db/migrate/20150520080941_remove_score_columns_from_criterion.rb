class RemoveScoreColumnsFromCriterion < ActiveRecord::Migration[4.2]
  def change
    remove_column :criteria, :score_min
    remove_column :criteria, :score_max
  end
end
