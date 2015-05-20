class CreateCalculators < ActiveRecord::Migration
  def change
    create_table :calculators do |t|
      t.string :class_name

      t.timestamps null: false
    end
  end
end
