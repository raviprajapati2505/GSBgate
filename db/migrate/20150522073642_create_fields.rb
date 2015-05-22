class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.string :label
      t.string :name
      t.references :calculator, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
