class RenameCalculatorClassNameToName < ActiveRecord::Migration
  def change
    rename_column(:calculators, :class_name, :name)
  end
end
