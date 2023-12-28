class CreateFieldData < ActiveRecord::Migration[4.2]
  def change
    create_table :field_data do |t|
      t.references :fields, index: true, foreign_key: true

      t.string :string_value
      t.integer :integer_value

      t.timestamps null: false
    end

    alter_table
  end
end
