class CreateRequirements < ActiveRecord::Migration
  def change
    create_table :requirements do |t|
      t.integer :reportable_id
      t.string :reportable_type

      t.timestamps null: false
    end
  end
end
