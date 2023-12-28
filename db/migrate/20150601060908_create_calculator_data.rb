class CreateCalculatorData < ActiveRecord::Migration[4.2]
  def change
    create_table :calculator_data do |t|
      t.references :calculator, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_column :field_data, :calculator_datum_id, :integer, :references => 'calculator_data'
  end
end
