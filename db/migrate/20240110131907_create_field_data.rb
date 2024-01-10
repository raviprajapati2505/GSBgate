class CreateFieldData < ActiveRecord::Migration[7.0]
  def change
    create_table :field_data do |t|
      t.references :fields, foreign_key: true, index: true
      t.references :calculator_datum, foreign_key: {to_table: :calculator_data}, index: true
      t.string :string_value
      t.integer :integer_value
      t.string :type

      t.timestamps null: false
    end
  end
end
