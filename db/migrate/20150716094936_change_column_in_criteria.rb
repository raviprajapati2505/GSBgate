class ChangeColumnInCriteria < ActiveRecord::Migration[4.2]
  def change
    change_column :criteria, :description, :text
    change_column :criteria, :measurement, :text
    change_column :criteria, :measurement_principle, :text
  end
end
