class CreateCalculators < ActiveRecord::Migration[4.2]
  def change
    create_table :calculators do |t|
      t.string :class_name

      t.timestamps null: false
    end
  end
end
