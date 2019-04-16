class CreateBuildingTypeGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :building_type_groups do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
