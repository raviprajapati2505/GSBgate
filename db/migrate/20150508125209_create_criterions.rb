class CreateCriterions < ActiveRecord::Migration
  def change
    create_table :criterions do |t|
      t.string :code, limit: 5
      t.string :name
      t.integer :score_min, limit: 1
      t.integer :score_max, limit: 1
      t.references :category, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :criterions, :code, unique: true
  end
end
