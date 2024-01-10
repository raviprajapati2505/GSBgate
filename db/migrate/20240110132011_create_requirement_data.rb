class CreateRequirementData < ActiveRecord::Migration[7.0]
  def change
    create_table :requirement_data do |t|
      t.references :requirement, foreign_key: true, index: true
      t.references :user, foreign_key: true, index: true
      t.integer :calculator_datum_id
      t.integer :status
      t.date :due_date

      t.timestamps null: false
    end
  end
end
