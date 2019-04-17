class RenameCalculatorClassNameToName < ActiveRecord::Migration[4.2]
  def change
    rename_column(:calculators, :class_name, :name)
  end
end
