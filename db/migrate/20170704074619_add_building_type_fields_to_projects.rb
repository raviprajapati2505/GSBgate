class AddBuildingTypeFieldsToProjects < ActiveRecord::Migration
  def change
    add_reference :projects, :building_type_group, index: true, foreign_key: true
    add_reference :projects, :building_type, index: true, foreign_key: true
  end
end
