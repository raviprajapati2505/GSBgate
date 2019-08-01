class AddVisibleToBuildingTypeGroupsAndBuildingTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :building_type_groups, :visible, :boolean, default: true
    add_column :building_types, :visible, :boolean, default: true
  end
end
