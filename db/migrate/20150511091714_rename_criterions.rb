class RenameCriterions < ActiveRecord::Migration[4.2]
  def change
    rename_table :criterions, :criteria
  end
end
