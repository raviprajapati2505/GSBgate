class ChangeColumnDefaultForShowAllCriteriaInCertificationPathsBis < ActiveRecord::Migration[4.2]
  def change
    change_column_default(:certification_paths, :show_all_criteria, true)
    CertificationPath.update_all(show_all_criteria: true)
  end
end
