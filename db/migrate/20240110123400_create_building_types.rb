class CreateBuildingTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :building_types do |t|
      t.string :name
      t.boolean :visible, defalut: true
      t.references :building_type_group, foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
