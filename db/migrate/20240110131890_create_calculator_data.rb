class CreateCalculatorData < ActiveRecord::Migration[7.0]
  def change
    create_table :calculator_data do |t|
      t.references :calculator, foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
