class RemoveScoreColumnsFromCriterion < ActiveRecord::Migration
  def change
    remove_column :criteria, :score_min
    remove_column :criteria, :score_max
  end
end
