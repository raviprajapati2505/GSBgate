class CreateCalculators < ActiveRecord::Migration[7.0]
  def change
    create_table :calculators do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
