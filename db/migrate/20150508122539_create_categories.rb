class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :code, limit: 2
      t.string :name
      t.integer :weight, limit: 3

      t.timestamps null: false
    end
    add_index :categories, :code, unique: true
  end
end
