class CreateBuildingTypeGroups < ActiveRecord::Migration
  def change
    create_table :building_type_groups do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
