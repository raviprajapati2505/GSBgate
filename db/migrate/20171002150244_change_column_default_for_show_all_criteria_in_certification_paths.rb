class ChangeColumnDefaultForShowAllCriteriaInCertificationPaths < ActiveRecord::Migration[4.2]
  def change
    change_column_default(:certification_paths, :show_all_criteria, false)
  end
end
