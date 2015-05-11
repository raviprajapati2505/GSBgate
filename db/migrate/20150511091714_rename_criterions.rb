class RenameCriterions < ActiveRecord::Migration
  def change
    rename_table :criterions, :criteria
  end
end
