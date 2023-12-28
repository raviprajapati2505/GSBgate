class CreateSchemeCriteria < ActiveRecord::Migration[4.2]
  def change
    create_table :scheme_criteria do |t|
      t.references :scheme, index: true, foreign_key: true
      t.references :criterion, index: true, foreign_key: true
      t.decimal :weight, precision: 3, scale: 2

      t.timestamps null: false
    end
  end
end
