class CreateRequirementData < ActiveRecord::Migration[4.2]
  def change
    create_table :requirement_data do |t|
      t.integer :reportable_data_id
      t.string :reportable_data_type

      t.timestamps null: false
    end
  end
end
