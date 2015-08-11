class RenameScoreClassName < ActiveRecord::Migration
  def change
    remove_column :scheme_criteria, :score_class_name
    add_column :scheme_criteria, :score_combination_type, :integer, default: 0
  end
end
