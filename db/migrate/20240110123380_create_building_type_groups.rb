class CreateBuildingTypeGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :building_type_groups do |t|
      t.string :name
      t.boolean :visible, default: true

      t.timestamps null: false
    end
  end
end
