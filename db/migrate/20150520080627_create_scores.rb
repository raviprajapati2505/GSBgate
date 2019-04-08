class CreateScores < ActiveRecord::Migration[4.2]
  def change
    create_table :scores do |t|
      t.integer :score
      t.text :description
      t.references :criterion, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
