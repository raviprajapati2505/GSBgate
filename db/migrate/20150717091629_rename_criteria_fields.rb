class RenameCriteriaFields < ActiveRecord::Migration
  def change
    rename_column :scheme_criteria, :score_type_a, :score_a
    rename_column :scheme_criteria, :score_type_b, :score_b
  end
end
