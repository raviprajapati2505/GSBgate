class CreateBuildingTypes < ActiveRecord::Migration
  def change
    create_table :building_types do |t|
      t.string :name
      t.references :building_type_group, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
