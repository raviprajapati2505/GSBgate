class CreateFields < ActiveRecord::Migration
  def change
    drop_table :fields
    create_table :fields do |t|
      t.references :calculator, index: true, foreign_key: true

      t.string :label
      t.string :name
      t.string :type
      t.string :validation

      t.timestamps null: false
    end
  end
end
